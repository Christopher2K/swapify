defmodule SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob do
  @moduledoc """
  Find for all the tracks in a given playlist
  user_id - User starting the search
  playlist_id - The id we should use to look for the track
  offset - The current track to look for in the playlist
  target_platform - The platform to look up the track on
  unsaved_tracks - The tracks that are waiting to be saved in the DB
  access_token - Access token to reach the search service
  refresh_token (optional)
  """

  require Logger
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.Accounts.Services.RefreshPartnerIntegration
  alias SwapifyApi.Accounts.Services.RemovePartnerIntegration
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.MusicProviders.Track
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker

  use Oban.Worker,
    queue: :search_track,
    max_attempts: 6

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, 427, _response}), do: {:error, :rate_limit}

  defp handle_error({:error, _, _}), do: {:error, :http_error}

  def search_track(
        "spotify",
        %{
          "user_id" => user_id,
          "playlist_id" => playlist_id,
          "offset" => offset,
          "unsaved_tracks" => unsaved_tracks,
          "access_token" => access_token,
          "refresh_token" => refresh_token
        } = args
      ) do
    case PlaylistRepo.get_playlist_track_by_index(playlist_id, offset) do
      {:ok, %Track{isrc: isrc}} when is_nil(isrc) ->
        # We don't have an isrc for this track, so just skip it
        Map.merge(args, %{"offset" => offset + 1})
        |> __MODULE__.new()
        |> Oban.insert()

      {:ok, %Track{isrc: isrc}} ->
        # 3. If it does exist, make a request to the corresponding platform API
        case Spotify.search_track(access_token, isrc) do
          {:ok, data, _} ->
            updated_unsaved_tracks =
              case data do
                [raw_track] ->
                  [
                    %{
                      "target_platform_id" => raw_track["id"],
                      "isrc" => isrc
                    }
                    | unsaved_tracks
                  ]

                _ ->
                  unsaved_tracks
              end

            # TODO: 4. If we reach a thresold, save in the DB and start the new job with the next offset with an empty array
            # TODO: 5. If not, add the item to the array and proceed to the next job

            Map.merge(args, %{"offset" => offset + 1, "unsaved_tracks" => updated_unsaved_tracks})
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
        # 2. If not exisiting, the job is done, save what we have in the array
        :ok
    end
  end

  def search_track(
        "applemusic",
        %{
          "playlist_id" => playlist_id,
          "offset" => offset,
          "unsaved_tracks" => unsaved_tracks,
          "access_token" => access_token,
          "user_id" => user_id
        } = args
      ) do
    search_limit = 25

    case PlaylistRepo.get_playlist_tracks(playlist_id, offset, search_limit) do
      {:ok, []} ->
        # Save the remaining tracks
        :ok

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
                          "target_platform_id" => track_match["id"],
                          "isrc" => isrc
                        }
                        | acc
                      ]

                    _ ->
                      acc
                  end
                end)
              )

            # TODO: 4. If we reach a thresold, save in the DB and start the new job with the next offset with an empty array
            # TODO: 5. If not, add the item to the array and proceed to the next job

            Map.merge(args, %{
              "offset" => offset + search_limit,
              "unsaved_tracks" => updated_unsaved_tracks
            })
            |> __MODULE__.new()
            |> Oban.insert()

          {:error, 401, _} ->
            RemovePartnerIntegration.call(user_id, :spotify)
            {:cancel, :authentication_error}

          error ->
            handle_error(error)
        end

      {:error, :not_found} ->
        # 2. If not exisiting, the job is done, save what we have in the array
        :ok
    end
  end

  @doc """
  Helper to build the base args map
  """
  @spec args(String.t(), Playlist.platform_name(), String.t(), String.t(), String.t() | nil) ::
          map()
  def args(
        playlist_id,
        target_platform,
        user_id,
        access_token,
        refresh_token \\ nil
      ) do
    %{
      "target_platform" => target_platform,
      "user_id" => user_id,
      "playlist_id" => playlist_id,
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
end
