defmodule SwapifyApi.MusicProviders.Jobs.SyncLibraryJob do
  @moduledoc """
  Synchronize a user playlist with Swapify database.
  Keep tracks in the database.

  Job arguments:
  - platform_name - spotify | applemusic
  - user_id - ID of the user - Useful for renewing / removing tokens
  - playlist_id - ID of the playlist row to update
  - offset - Offset to start the request
  - access_token
  - refresh_token - Optional

  The `job_id` should be added to the jobs args for the job to work

  On success, returns a `{:ok, %JobUpdateNotification{}}`
  """
  alias SwapifyApi.Tasks
  alias SwapifyApi.MusicProviders
  alias SwapifyApi.Accounts
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Notifications.JobErrorNotification
  alias SwapifyApi.Notifications.JobUpdateNotification
  alias SwapifyApi.Tasks.TaskEventHandler
  alias SwapifyApi.Utils
  alias SwapifyApiWeb.JobUpdateChannel

  require Logger

  use Oban.Worker,
    queue: :sync_library,
    max_attempts: 6,
    unique: [
      keys: [:user_id, :playlist_id, :offset, :access_token],
      states: [:available, :scheduled, :executing, :retryable]
    ]

  use TaskEventHandler, job_module: Utils.get_module_name(__MODULE__)

  @spotify_limit 50
  @apple_music_limit 100

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, :service_427}), do: {:error, :rate_limit}

  defp save_tracks(
         %{
           "platform_name" => platform_name,
           "playlist_id" => playlist_id,
           "offset" => offset,
           "job_id" => job_id
         } = args,
         tracks,
         tracks_total,
         has_next?,
         platform_limit
       ) do
    new_status = if has_next?, do: :syncing, else: :synced
    next_offset = offset + platform_limit

    PlaylistRepo.add_tracks(
      playlist_id,
      tracks,
      tracks_total,
      new_status,
      replace_tracks: offset == 0
    )
    |> case do
      {:ok, _} ->
        with {:ok, _} <-
               (if has_next? do
                  Map.merge(args, %{
                    "offset" => next_offset
                  })
                  |> __MODULE__.new()
                  |> Oban.insert()
                else
                  Tasks.update_job_status(job_id, :done)
                end) do
          Logger.debug("Fetched library items",
            platform_name: platform_name,
            has_next: has_next?,
            total: tracks_total
          )

          {:ok,
           notification:
             JobUpdateNotification.new_library_sync_update(
               playlist_id,
               platform_name,
               tracks_total,
               offset + length(tracks),
               if(has_next?, do: :syncing, else: :synced)
             )}
        end

      {:error, error} ->
        Logger.error("Failed to update playlist #{inspect(error)}",
          platform_name: platform_name,
          error: error
        )

        {:error, :database_error}
    end
  end

  defp fetch_tracks(
         %{
           "platform_name" => "spotify",
           "offset" => offset,
           "user_id" => user_id,
           "access_token" => access_token,
           "refresh_token" => refresh_token
         } = args
       ) do
    case Spotify.get_user_library(access_token, offset) do
      {:ok, tracks, response} ->
        total = response.body["total"]
        has_next? = response.body["next"] != nil

        save_tracks(args, tracks, total, has_next?, @spotify_limit)

      {:error, :service_401} ->
        case Accounts.refresh_partner_integration(user_id, :spotify, refresh_token) do
          {:ok, refreshed_pc} ->
            Logger.info("Restart the job with new credentials", platform_name: "spotify")

            Map.merge(args, %{
              "access_token" => refreshed_pc.access_token,
              "refresh_token" => refreshed_pc.refresh_token
            })
            |> __MODULE__.new()
            |> Oban.insert()

            {:cancel, :authentication_renewed}

          {:error, _} ->
            {:cancel, :authentication_error}
        end

      error ->
        handle_error(error)
    end
  end

  defp fetch_tracks(
         %{
           "platform_name" => "applemusic",
           "offset" => offset,
           "user_id" => user_id,
           "access_token" => access_token
         } = args
       ) do
    developer_token = AppleMusicTokenWorker.get()

    case AppleMusic.get_user_library(developer_token, access_token, offset) do
      {:ok, tracks, response} ->
        total = response.body["meta"]["total"]
        has_next? = response.body["next"] != nil

        save_tracks(args, tracks, total, has_next?, @apple_music_limit)

      {:error, :service_401} ->
        Accounts.disable_partner_integration(user_id, :applemusic)
        {:cancel, :authentication_error}

      error ->
        handle_error(error)
    end
  end

  @doc """
  Helper to build the base args map
  """
  @spec args(String.t(), Playlist.platform_name(), String.t(), String.t(), String.t() | nil) ::
          map()
  def args(
        playlist_id,
        platform_name,
        user_id,
        access_token,
        refresh_token \\ nil
      ) do
    %{
      "platform_name" => platform_name,
      "user_id" => user_id,
      "playlist_id" => playlist_id,
      "access_token" => access_token,
      "refresh_token" => refresh_token,
      "offset" => 0
    }
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: args
      }) do
    fetch_tracks(args)
  end

  # EVENT HANDLERS

  handle :started do
    Logger.info("Sync Library job started",
      user_id: job_args["user_id"],
      service: job_args["service"]
    )
  end

  handle :success do
    {:ok, notification: notification} = result

    JobUpdateChannel.broadcast_job_progress(
      job_args["user_id"],
      notification
    )

    Logger.info("Sync Library job finished",
      user_id: job_args["user_id"],
      service: job_args["service"]
    )
  end

  handle :error do
    Logger.info("Sync Library job error",
      user_id: job_args["user_id"],
      service: job_args["service"]
    )
  end

  handle :failure do
    handle_playlist_sync_error(job_args)

    Logger.info("Sync Library job failure (max attempt exceeded)",
      user_id: job_args["user_id"],
      service: job_args["service"]
    )
  end

  handle :cancelled do
    handle_playlist_sync_error(job_args)

    Logger.info("Sync Library job cancelled",
      user_id: job_args["user_id"],
      service: job_args["service"]
    )
  end

  handle :catch_all do
    :ok
  end

  defp handle_playlist_sync_error(%{
         "user_id" => user_id,
         "playlist_id" => playlist_id,
         "job_id" => job_id,
         "platform_name" => platform_name
       }) do
    JobUpdateChannel.broadcast_job_progress(
      user_id,
      JobErrorNotification.new_library_sync_error(
        playlist_id,
        platform_name
      )
    )

    Task.await_many([
      Task.async(fn ->
        MusicProviders.mark_playlist_transfer_as_failed(playlist_id)
      end),
      Task.async(fn ->
        Tasks.update_job_status(job_id, :error)
      end)
    ])
  end
end
