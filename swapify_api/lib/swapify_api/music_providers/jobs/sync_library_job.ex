defmodule SwapifyApi.MusicProviders.Jobs.SyncLibraryJob do
  @moduledoc """
  Synchronize a user playlist with Swapify database.
  Keep tracks in the database.

  Job arguments:
  - platform_name - spotify | applemusic
  - user_id - ID of the user - Useful for renewing / removing tokens
  - playlist_id - ID of the playlist row to update
  - offset - Offset to start the request
  - synced_tracks_count - nil for the first job
  - tracks_count -  nil for the first job
  - access_token
  - refresh_token - Optional
  """
  require Logger

  use Oban.Worker,
    queue: :sync_library,
    max_attempts: 6,
    unique: [
      keys: [:user_id, :playlist_id, :offset, :access_token],
      states: [:available, :scheduled, :executing, :retryable]
    ]

  alias SwapifyApi.Accounts.Services.RefreshPartnerIntegration
  alias SwapifyApi.Accounts.Services.RemovePartnerIntegration
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.MusicProviders.SyncNotification

  @spotify_limit 50
  @apple_music_limit 100

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, 427, _response}), do: {:error, :rate_limit}

  defp handle_error({:error, _, _}), do: {:error, :http_error}

  defp save_tracks(
         %{
           "platform_name" => platform_name,
           "playlist_id" => playlist_id,
           "offset" => offset
         } = args,
         tracks,
         tracks_total,
         has_next?,
         platform_limit
       ) do
    new_status = if has_next?, do: :syncing, else: :synced

    PlaylistRepo.add_tracks(
      playlist_id,
      tracks,
      tracks_total,
      new_status,
      replace_tracks: offset == 0
    )
    |> case do
      {:ok, _} ->
        if has_next? do
          Map.merge(args, %{
            "offset" => offset + platform_limit,
            "tracks_total" => tracks_total,
            "synced_tracks_count" => offset + length(tracks)
          })
          |> __MODULE__.new()
          |> Oban.insert()
        end

        Logger.debug("Fetched library items",
          platform_name: platform_name,
          has_next: has_next?,
          total: tracks_total
        )

        :ok

      {:error, error} ->
        Logger.error("Failed to update playlist", platform_name: platform_name, error: error)
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

      {:error, 401, _} ->
        case RefreshPartnerIntegration.call(user_id, "spotify", refresh_token) do
          {:ok, refreshed_pc} ->
            Logger.info("Restart the job with new credentials", platform_name: "spotify")

            Map.merge(args, %{
              "access_token" => refreshed_pc.access_token,
              "refresh_token" => refreshed_pc.refresh_token
            })
            |> __MODULE__.new()
            |> Oban.insert()

            :ok

          {:error, _} ->
            RemovePartnerIntegration.call(user_id, :spotify)
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
        RemovePartnerIntegration.call(user_id, :applemusic)
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
      "offset" => 0,
      "synced_tracks_count" => 0,
      "tracks_count" => 0
    }
  end

  @doc """
  Helper to build the sync notification
  """
  @spec to_notification(map(), Playlist.sync_status()) :: SyncNotification.t()
  def to_notification(
        %{
          "playlist_id" => playlist_id,
          "platform_name" => platform_name,
          "tracks_count" => tracks_count,
          "synced_tracks_count" => synced_tracks_count
        },
        status
      ),
      do: %SyncNotification{
        playlist_id: playlist_id,
        platform_name: platform_name,
        tracks_count: tracks_count,
        sync_count: synced_tracks_count,
        status: status
      }

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: args
      }) do
    fetch_tracks(args)
  end
end
