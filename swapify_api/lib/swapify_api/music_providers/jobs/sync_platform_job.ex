defmodule SwapifyApi.MusicProviders.Jobs.SyncPlatformJob do
  @moduledoc """
  Synchronize the playlists and the library data for a specific platform

  Job arguments:
  - platform_name - spotify | applemusic
  - user_id - ID of the user - Useful for renewing / removing tokens
  - access_token
  - refresh_token - Optional
  - offset

  The `job_id` should be added to the jobs args for the job to work

  On success, returns a `{:ok, %JobUpdateNotification{}}`
  """
  alias SwapifyApi.Tasks
  alias SwapifyApi.MusicProviders
  alias SwapifyApi.Utils
  alias SwapifyApi.Accounts
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Tasks.TaskEventHandler
  alias SwapifyApi.Notifications.JobErrorNotification
  alias SwapifyApi.Notifications.JobUpdateNotification
  alias SwapifyApiWeb.JobUpdateChannel

  require Logger

  use Oban.Worker,
    queue: :sync_platform,
    max_attempts: 6,
    unique: [
      keys: [:platform_name, :user_id, :access_token],
      states: [:available, :scheduled, :executing, :retryable]
    ]

  use TaskEventHandler, job_module: Utils.get_module_name(__MODULE__)

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, %{details: %{status: 427}}}), do: {:error, :rate_limit}

  @spec args(String.t(), Playlist.platform_name(), String.t(), String.t(), String.t() | nil) ::
          map()
  def args(
        platform_name,
        user_id,
        access_token,
        refresh_token \\ nil,
        should_sync_library?
      ) do
    %{
      "platform_name" => platform_name,
      "user_id" => user_id,
      "access_token" => access_token,
      "refresh_token" => refresh_token,
      "should_sync_library" => should_sync_library?,
      "offset" => 0
    }
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args:
          %{
            "platform_name" => "spotify",
            "user_id" => user_id,
            "access_token" => access_token,
            "refresh_token" => refresh_token,
            "should_sync_library" => true,
            "job_id" => job_id
          } = args
      }) do
    case Spotify.get_user_library(access_token) do
      {:ok, _tracks, response} ->
        total = response.body["total"]

        with {:ok, _} <- MusicProviders.sync_playlist_metadata(:spotify, user_id, total),
             {:ok, _} <- Tasks.update_job_status(job_id, :done) do
          {:ok, notification: JobUpdateNotification.new_platform_sync_update("spotify", :done)}
        end

      {:error, %{details: %{status: 401}}} ->
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

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "platform_name" => "applemusic",
          "user_id" => user_id,
          "access_token" => access_token,
          "should_sync_library" => true,
          "job_id" => job_id
        }
      }) do
    developer_token = AppleMusicTokenWorker.get()

    case AppleMusic.get_user_library(developer_token, access_token) do
      {:ok, _tracks, response} ->
        total = response.body["meta"]["total"]

        with {:ok, _} <- MusicProviders.sync_playlist_metadata(:applemusic, user_id, total),
             {:ok, _} <- Tasks.update_job_status(job_id, :done) do
          {:ok, notification: JobUpdateNotification.new_platform_sync_update("applemusic", :done)}
        end

      {:error, %{details: %{status: 401}}} ->
        Accounts.disable_partner_integration(user_id, :applemusic)
        {:cancel, :authentication_error}

      error ->
        handle_error(error)
    end
  end

  # EVENTS HANDLER

  handle :started do
    Logger.info("Sync Platform job started",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :cancelled do
    handle_platform_job_error(job_args)

    Logger.info("Sync Platform cancelled",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )

    Tasks.update_job_status(job_args["job_id"], :error)
  end

  handle :success do
    {:ok, notification: notification} = result

    JobUpdateChannel.broadcast_job_progress(job_args["user_id"], notification)

    Logger.info("Sync Platform job finished",
      user_id: job_args["user_id"],
      service: job_args["platform_name"],
      result: inspect(result)
    )
  end

  handle :failure do
    handle_platform_job_error(job_args)

    Logger.info("Sync Platform job failure(max attempt exceeded)",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :error do
    Logger.info("Sync Library job error",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :catch_all do
    :ok
  end

  defp handle_platform_job_error(%{
         "job_id" => job_id,
         "user_id" => user_id,
         "platform_name" => platform_name
       }) do
    JobUpdateChannel.broadcast_job_progress(
      user_id,
      JobErrorNotification.new_platform_sync_error(platform_name)
    )

    Task.async(fn ->
      Tasks.update_job_status(job_id, :error)
    end)
  end
end
