defmodule SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob do
  @moduledoc """
  Find for all the tracks in a given playlist

  Job arguments:
  - user_id - User starting the search
  - playlist_id - The id we should use to look for the track
  - transfer_id - the transfer this find job belongs to and must update
  - offset - The current track to look for in the playlist
  - target_platform - The platform to look up the track on
  - unsaved_tracks - The tracks that are waiting to be saved in the DB
  - unsaved_not_found_tracks - The tracks that could not be found but yet hasn't been synced to the DB
  - access_token - Access token to reach the search service
  - refresh_token (optional)


  On success, returns a `{:ok, %JobUpdateNotification{}}`
  """
  alias Mix.Tasks
  alias SwapifyApi.Tasks
  alias SwapifyApi.Utils
  alias SwapifyApi.Accounts
  alias SwapifyApi.Tasks.TransferRepo
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.MusicProviders.Track
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.Tasks.MatchedTrack
  alias SwapifyApi.Tasks.TaskEventHandler
  alias SwapifyApi.MusicProviders.Track
  alias SwapifyApi.Notifications.JobErrorNotification
  alias SwapifyApi.Notifications.JobUpdateNotification
  alias SwapifyApiWeb.JobUpdateChannel

  require Logger

  use Oban.Worker,
    queue: :search_tracks,
    max_attempts: 6

  use TaskEventHandler, job_module: Utils.get_module_name(__MODULE__)

  @unsaved_threshold 50

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, :service_427}), do: {:error, :rate_limit}

  defp process_match_results(matched_tracks, transfer_id, should_force_update? \\ false) do
    should_update? = should_force_update? || length(matched_tracks) >= @unsaved_threshold

    if should_update? do
      with mt_list <-
             Enum.map(matched_tracks, fn mt ->
               %MatchedTrack{
                 isrc: mt["isrc"],
                 platform_id: mt["platform_id"],
                 platform_link: mt["platform_link"]
               }
             end),
           {:ok, _} = TransferRepo.add_matched_tracks(transfer_id, mt_list) do
        {:ok, []}
      end
    else
      {:ok, matched_tracks}
    end
  end

  defp process_error_results(not_found_tracks, transfer_id, should_force_update? \\ false) do
    should_update? = should_force_update? || length(not_found_tracks) >= @unsaved_threshold

    if should_update? do
      with track_list <-
             Enum.map(not_found_tracks, fn t ->
               %Track{
                 name: t["name"],
                 album: t["album"],
                 isrc: t["isrc"],
                 artists: t["artists"]
               }
             end),
           {:ok, _} = TransferRepo.add_not_found_tracks(transfer_id, track_list) do
        {:ok, []}
      end
    else
      {:ok, not_found_tracks}
    end
  end

  def search_track(
        "spotify",
        %{
          "user_id" => user_id,
          "playlist_id" => playlist_id,
          "offset" => offset,
          "unsaved_tracks" => unsaved_tracks,
          "unsaved_not_found_tracks" => unsaved_not_found_tracks,
          "access_token" => access_token,
          "refresh_token" => refresh_token,
          "transfer_id" => transfer_id,
          "job_id" => job_id
        } = args
      ) do
    case PlaylistRepo.get_playlist_track_by_index(playlist_id, offset) do
      {:error, :not_found} ->
        with {:ok, _} <- process_match_results(unsaved_tracks, transfer_id, true),
             {:ok, _} <- process_error_results(unsaved_not_found_tracks, transfer_id, true),
             {:ok, _} <- Tasks.update_job_status(job_id, :done) do
          {:ok,
           notification:
             JobUpdateNotification.new_search_tracks_update(
               transfer_id,
               playlist_id,
               "spotify",
               offset,
               :done
             )}
        end

      {:ok, track} ->
        case Spotify.search_track(access_token, %{
               "isrc" => track.isrc,
               "name" => track.name,
               "album" => track.album,
               "artist" => Enum.at(track.artists, 0)
             }) do
          {:ok, nil, _} ->
            with {:ok, updated_unsaved_not_found_tracks} <-
                   [Track.to_map(track) | unsaved_not_found_tracks]
                   |> process_error_results(transfer_id),
                 {:ok, _} <-
                   Map.merge(args, %{
                     "offset" => offset + 1,
                     "unsaved_not_found_tracks" => updated_unsaved_not_found_tracks
                   })
                   |> __MODULE__.new()
                   |> Oban.insert() do
              {:ok,
               notification:
                 JobUpdateNotification.new_search_tracks_update(
                   transfer_id,
                   playlist_id,
                   "spotify",
                   offset,
                   :started
                 )}
            end

          {:ok, matched_track, _} ->
            with {:ok, tracks} <-
                   [
                     MatchedTrack.to_map(matched_track)
                     | unsaved_tracks
                   ]
                   |> process_match_results(transfer_id),
                 {:ok, _} <-
                   Map.merge(args, %{
                     "offset" => offset + 1,
                     "unsaved_tracks" => tracks
                   })
                   |> __MODULE__.new()
                   |> Oban.insert() do
              {:ok,
               notification:
                 JobUpdateNotification.new_search_tracks_update(
                   transfer_id,
                   playlist_id,
                   "spotify",
                   offset,
                   :started
                 )}
            end

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
  end

  def search_track(
        "applemusic",
        %{
          "playlist_id" => playlist_id,
          "offset" => offset,
          "unsaved_tracks" => unsaved_tracks,
          "unsaved_not_found_tracks" => unsaved_not_found_tracks,
          "access_token" => access_token,
          "user_id" => user_id,
          "transfer_id" => transfer_id,
          "job_id" => job_id
        } = args
      ) do
    case PlaylistRepo.get_playlist_track_by_index(playlist_id, offset) do
      {:error, :not_found} ->
        with {:ok, _} <- process_match_results(unsaved_tracks, transfer_id, true),
             {:ok, _} <- process_error_results(unsaved_not_found_tracks, transfer_id, true),
             {:ok, _} <- Tasks.update_job_status(job_id, :done) do
          {:ok,
           notification:
             JobUpdateNotification.new_search_tracks_update(
               transfer_id,
               playlist_id,
               "applemusic",
               offset,
               :done
             )}
        end

      {:ok, track} ->
        developer_token = AppleMusicTokenWorker.get()

        search_args = %{
          "album" => track.album,
          "artist" => track.artists |> Enum.at(0),
          "name" => track.name,
          "isrc" => track.isrc
        }

        case AppleMusic.search_track(developer_token, access_token, search_args) do
          {:ok, nil, _} ->
            with {:ok, updated_unsaved_not_found_tracks} <-
                   [Track.to_map(track) | unsaved_not_found_tracks]
                   |> process_error_results(transfer_id),
                 {:ok, _} <-
                   Map.merge(args, %{
                     "offset" => offset + 1,
                     "unsaved_not_found_tracks" => updated_unsaved_not_found_tracks
                   })
                   |> __MODULE__.new()
                   |> Oban.insert() do
              {:ok,
               notification:
                 JobUpdateNotification.new_search_tracks_update(
                   transfer_id,
                   playlist_id,
                   "applemusic",
                   offset,
                   :started
                 )}
            end

          {:ok, matched_track, _} ->
            with {:ok, updated_unsaved_tracks} <-
                   [MatchedTrack.to_map(matched_track) | unsaved_tracks]
                   |> process_match_results(transfer_id),
                 {:ok, _} <-
                   Map.merge(args, %{
                     "offset" => offset + 1,
                     "unsaved_tracks" => updated_unsaved_tracks
                   })
                   |> __MODULE__.new()
                   |> Oban.insert() do
              {:ok,
               notification:
                 JobUpdateNotification.new_search_tracks_update(
                   transfer_id,
                   playlist_id,
                   "applemusic",
                   offset,
                   :started
                 )}
            end

          {:error, :service_401} ->
            Accounts.remove_partner_integration(user_id, :applemusic)
            {:cancel, :authentication_error}

          error ->
            handle_error(error)
        end
    end
  end

  @doc """
  Helper to build the base args map
  """
  @spec args(
          String.t(),
          Playlist.platform_name(),
          String.t(),
          String.t(),
          String.t(),
          String.t() | nil
        ) ::
          map()
  def args(
        playlist_id,
        target_platform,
        transfer_id,
        user_id,
        access_token,
        refresh_token \\ nil
      ) do
    %{
      "target_platform" => target_platform,
      "user_id" => user_id,
      "playlist_id" => playlist_id,
      "transfer_id" => transfer_id,
      "access_token" => access_token,
      "refresh_token" => refresh_token,
      "offset" => 0,
      "unsaved_tracks" => [],
      "unsaved_not_found_tracks" => []
    }
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: args
      }) do
    search_track(args["target_platform"], args)
  end

  handle :started do
    Logger.info("FindPlaylistTracks job started",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :success do
    {:ok, notification: notification} = result

    JobUpdateChannel.broadcast_job_progress(
      job_args["user_id"],
      notification
    )

    Logger.info("FindPlaylistTracks job finished",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :cancelled do
    handle_playlist_sync_error(job_args)

    Logger.info("FindPlaylistTracks job cancelled",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :failure do
    handle_playlist_sync_error(job_args)

    Logger.info("FindPlaylistTracks job failure(max attempt exceeded)",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :error do
    Logger.info("FindPlaylistTracks job error",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :catch_all do
    :ok
  end

  defp handle_playlist_sync_error(%{
         "user_id" => user_id,
         "playlist_id" => playlist_id,
         "job_id" => job_id,
         "platform_name" => platform_name,
         "transfer_id" => transfer_id
       }) do
    JobUpdateChannel.broadcast_job_progress(
      user_id,
      JobErrorNotification.new_search_tracks_error(
        transfer_id,
        playlist_id,
        platform_name
      )
    )

    Task.async(fn ->
      Tasks.update_job_status(job_id, :error)
    end)
  end
end
