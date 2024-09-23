defmodule SwapifyApi.MusicProviders.Jobs.TransferTracksJob do
  @moduledoc """
  Transfer all the tracks found to the destination platform

  user_id - User starting the transfer
  transfer_id - the transfer this find job belongs to and must update
  offset - The current track to look for in the matched_tracks array
  target_platform - The platform where the tracks should be added
  is_library - Tells if the target is the library playlist
  access_token - Access token to reach the search service
  refresh_token (optional)

  job_id is needed for this job to work
  """
  alias SwapifyApi.Accounts.Services.RefreshPartnerIntegration
  alias SwapifyApi.Accounts.Services.RemovePartnerIntegration
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.MusicProviders.Track
  alias SwapifyApi.Tasks.Services.UpdateJobStatus
  alias SwapifyApi.Tasks.TaskEventHandler
  alias SwapifyApi.Tasks.TransferRepo
  alias SwapifyApi.Utils

  require Logger

  use Oban.Worker,
    queue: :transfer_tracks,
    max_attempts: 6

  use TaskEventHandler, job_module: Utils.get_module_name(__MODULE__)

  @spotify_add_limit 50

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, 427, _response}), do: {:error, :rate_limit}

  defp handle_error({:error, _, _}), do: {:error, :http_error}

  def transfer(
        "spotify",
        %{
          "user_id" => user_id,
          "offset" => offset,
          "access_token" => access_token,
          "refresh_token" => refresh_token,
          "transfer_id" => transfer_id,
          "job_id" => job_id,
          "is_library" => true
        } = args
      ) do
    case TransferRepo.get_matched_tracks(transfer_id, offset, @spotify_add_limit) do
      {:ok, []} ->
        UpdateJobStatus.call(job_id, :done)

      {:ok, tracks} ->
        with {:ok, _} <-
               Spotify.add_tracks_to_library(
                 access_token,
                 Enum.map(tracks, fn mt -> mt.platform_id end)
               ) do
          Map.merge(args, %{
            "offset" => offset + @spotify_add_limit
          })
          |> __MODULE__.new()
          |> Oban.insert()
        else
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
    end
  end

  # def transfer(
  #       "applemusic",
  #       %{
  #         "playlist_id" => playlist_id,
  #         "offset" => offset,
  #         "unsaved_tracks" => unsaved_tracks,
  #         "unsaved_not_found_tracks" => unsaved_not_found_tracks,
  #         "access_token" => access_token,
  #         "user_id" => user_id,
  #         "transfer_id" => transfer_id,
  #         "job_id" => job_id
  #       } = args
  #     ) do
  # end

  @doc """
  Helper to build the base args map
  """
  @spec args(
          String.t(),
          String.t(),
          Playlist.platform_name(),
          boolean(),
          String.t(),
          String.t() | nil
        ) ::
          map()
  def args(
        user_id,
        transfer_id,
        target_platform,
        is_library,
        access_token,
        refresh_token \\ nil
      ) do
    %{
      "user_id" => user_id,
      "target_platform" => target_platform,
      "transfer_id" => transfer_id,
      "is_library" => is_library,
      "access_token" => access_token,
      "refresh_token" => refresh_token,
      "offset" => 0
    }
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: args
      }) do
    transfer(args["target_platform"], args)
  end

  handle :started do
    Logger.info("TransferTracks job started",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :cancelled do
    Logger.info("TransferTracks job cancelled",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )

    UpdateJobStatus.call(job_args["job_id"], :error)
  end

  handle :success do
    _result = result

    Logger.info("TransferTracks job finished",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :failure do
    Logger.info("TransferTracks job failure(max attempt exceeded)",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )

    UpdateJobStatus.call(job_args["job_id"], :error)
  end

  handle :error do
    Logger.info("TransferTracks job error",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :catch_all do
    :ok
  end
end