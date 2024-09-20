defmodule SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob do
  @moduledoc """
  Find for all the tracks in a given playlist
  user_id - User starting the search
  playlist_id - The id we should use to look for the track
  transfer_id - the transfer this find job belongs to and must update
  offset - The current track to look for in the playlist
  target_platform - The platform to look up the track on
  unsaved_tracks - The tracks that are waiting to be saved in the DB
  access_token - Access token to reach the search service
  refresh_token (optional)
  """
  alias SwapifyApi.Utils
  alias SwapifyApi.Tasks.TransferRepo
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.Accounts.Services.RefreshPartnerIntegration
  alias SwapifyApi.Accounts.Services.RemovePartnerIntegration
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.MusicProviders.Track
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.Tasks.MatchedTrack
  alias SwapifyApi.Tasks.TaskEventHandler
  alias SwapifyApi.Tasks.Services.UpdateJobStatus

  require Logger

  use Oban.Worker,
    queue: :search_tracks,
    max_attempts: 6

  use TaskEventHandler, job_module: Utils.get_module_name(__MODULE__)

  @unsaved_threshold 50

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, 427, _response}), do: {:error, :rate_limit}

  defp handle_error({:error, _, _}), do: {:error, :http_error}

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

  def search_track(
        "spotify",
        %{
          "user_id" => user_id,
          "playlist_id" => playlist_id,
          "offset" => offset,
          "unsaved_tracks" => unsaved_tracks,
          "access_token" => access_token,
          "refresh_token" => refresh_token,
          "transfer_id" => transfer_id,
          "job_id" => job_id
        } = args
      ) do
    case PlaylistRepo.get_playlist_track_by_index(playlist_id, offset) do
      {:ok, %Track{isrc: isrc}} when is_nil(isrc) ->
        # We don't have an isrc for this track, so just skip it
        Map.merge(args, %{"offset" => offset + 1})
        |> __MODULE__.new()
        |> Oban.insert()

      {:ok, %Track{isrc: isrc}} ->
        case Spotify.search_track(access_token, isrc) do
          {:ok, [match_result | _], _} ->
            updated_unsaved_tracks =
              [
                %{
                  "platform_link" => match_result["href"],
                  "platform_id" => match_result["id"],
                  "isrc" => isrc
                }
                | unsaved_tracks
              ]
              |> process_match_results(transfer_id)

            with {:ok, tracks} <- updated_unsaved_tracks do
              Map.merge(args, %{
                "offset" => offset + 1,
                "unsaved_tracks" => tracks
              })
              |> __MODULE__.new()
              |> Oban.insert()
            end

          {:ok, [], _} ->
            Map.merge(args, %{
              "offset" => offset + 1
            })
            |> __MODULE__.new()
            |> Oban.insert()

          {:error, 401, _} ->
            case RefreshPartnerIntegration.call(user_id, :spotify, refresh_token) do
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
                RemovePartnerIntegration.call(user_id, :spotify)
                {:cancel, :authentication_error}
            end

          error ->
            handle_error(error)
        end

      {:error, :not_found} ->
        process_match_results(unsaved_tracks, transfer_id, true)

        UpdateJobStatus.call(job_id, :done)
    end
  end

  def search_track(
        "applemusic",
        %{
          "playlist_id" => playlist_id,
          "offset" => offset,
          "unsaved_tracks" => unsaved_tracks,
          "access_token" => access_token,
          "user_id" => user_id,
          "transfer_id" => transfer_id,
          "job_id" => job_id
        } = args
      ) do
    search_limit = 25

    case PlaylistRepo.get_playlist_tracks(playlist_id, offset, search_limit) do
      {:ok, []} ->
        process_match_results(unsaved_tracks, transfer_id, true)

        UpdateJobStatus.call(job_id, :done)

      {:ok, track_list} ->
        developer_token = AppleMusicTokenWorker.get()

        isrc_list =
          track_list
          |> Enum.reduce([], fn track, acc ->
            if track.isrc != nil, do: [track.isrc | acc], else: acc
          end)

        case AppleMusic.search_tracks(developer_token, access_token, isrc_list) do
          {:ok, data, _} ->
            updated_unsaved_tracks =
              Enum.concat(
                unsaved_tracks,
                Enum.reduce(isrc_list, [], fn isrc, acc ->
                  case data["meta"]["filters"]["isrc"][isrc] do
                    [track_match | _] ->
                      [
                        %{
                          "platform_link" => track_match["href"],
                          "platform_id" => track_match["id"],
                          "isrc" => isrc
                        }
                        | acc
                      ]

                    _ ->
                      acc
                  end
                end)
              )

            with {:ok, updated_unsaved_tracks} <-
                   process_match_results(updated_unsaved_tracks, transfer_id) do
              Map.merge(args, %{
                "offset" => offset + search_limit,
                "unsaved_tracks" => updated_unsaved_tracks
              })
              |> __MODULE__.new()
              |> Oban.insert()
            end

          {:error, 401, _} ->
            RemovePartnerIntegration.call(user_id, :spotify)
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
      "unsaved_tracks" => []
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

  handle :cancelled do
    Logger.info("FindPlaylistTracks job cancelled",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )

    UpdateJobStatus.call(job_args["job_id"], :error)
  end

  handle :success do
    Logger.info("FindPlaylistTracks job finished",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :failure do
    Logger.info("FindPlaylistTracks job failure(max attempt exceeded)",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )

    UpdateJobStatus.call(job_args["job_id"], :error)
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
end
