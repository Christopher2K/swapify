defmodule SwapifyApi.MusicProviders.Jobs.SyncLibraryJob do
  @moduledoc """
  Synchronize a user playlist with Swapify database.
  Keep tracks in the database.

  Job arguments:
  - service - spotify | applemusic
  - playlist_id - ID of the playlist to update
  - offset - Offset to start the request
  - user_id
  - access_token
  - refresh_token - Optional
  `
    "service" => service,
    "playlist_id" => playlist_id,
    "offset" => offset,
    "user_id" => user_id,
    "access_token" => access_token,
    "refresh_token" => refresh_token
  `
  """
  require Logger
  use Oban.Worker, queue: :sync_library, max_attempts: 6

  alias SwapifyApi.Accounts.Services.RefreshPartnerIntegration
  alias SwapifyApi.Accounts.Services.RemovePartnerIntegration
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.MusicProviders.Track

  @spotify_limit 50
  @apple_music_limit 100

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, 427, _response}), do: {:error, :rate_limit}

  defp handle_error({:error, _, _}), do: {:error, :http_error}

  defp save_tracks(
         %{
           "service" => service,
           "playlist_id" => playlist_id,
           "offset" => offset,
           "user_id" => user_id
         } = args,
         tracks,
         tracks_total,
         has_next?,
         service_limit
       ) do
    new_status = if has_next?, do: :syncing, else: :synced

    updated_playlist_result =
      case playlist_id do
        nil ->
          PlaylistRepo.create(%{
            "user_id" => user_id,
            "platform_name" => service,
            "platform_id" => "library",
            "tracks_total" => tracks_total,
            "tracks" => tracks |> Enum.map(&Track.to_map/1),
            "sync_status" => new_status
          })

        id ->
          PlaylistRepo.update(
            id,
            %{"sync_status" => new_status, "tracks_total" => tracks_total, "+tracks" => tracks}
          )
      end

    case updated_playlist_result do
      {:ok, %{id: updated_playlist_id}} ->
        if has_next? do
          %{args | "offset" => offset + service_limit, "playlist_id" => updated_playlist_id}
          |> __MODULE__.new()
          |> Oban.insert()
        end

        Logger.debug("Fetched library items",
          service: service,
          has_next: has_next?,
          total: tracks_total
        )

        :ok

      {:error, error} ->
        Logger.error("Failed to update playlist", service: service, error: error)
        {:error, :database_error}
    end
  end

  defp fetch_tracks(
         %{
           "service" => "spotify",
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
            Logger.info("Restart the job with new credentials", service: "spotify")

            %{
              args
              | "access_token" => refreshed_pc.access_token,
                "refresh_token" => refreshed_pc.refresh_token
            }
            |> __MODULE__.new()
            |> Oban.insert()

            :ok

          {:error, _} ->
            {:cancel, :authentication_error}
        end

      error ->
        handle_error(error)
    end
  end

  defp fetch_tracks(
         %{
           "service" => "applemusic",
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

      {:error, 401, _} ->
        RemovePartnerIntegration.call(user_id, "applemusic")
        {:cancel, :authentication_error}

      error ->
        handle_error(error)
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: args
      }) do
    fetch_tracks(args)
  end
end
