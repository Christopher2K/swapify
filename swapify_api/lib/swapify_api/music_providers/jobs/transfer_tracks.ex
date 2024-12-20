defmodule SwapifyApi.MusicProviders.Jobs.TransferTracksJob do
  @moduledoc """
  Transfer all the tracks found to the destination platform

  Job arguments:
  - user_id - User starting the transfer
  - transfer_id - the transfer this find job belongs to and must update
  - offset - The current track to look for in the matched_tracks array
  - target_platform - The platform where the tracks should be added
  - is_library - Tells if the target is the library playlist
  - access_token - Access token to reach the search service
  - refresh_token (optional)

  The `job_id` is needed for this job to work
  On success, returns a `{:ok, %JobUpdateNotification{}}`
  """
  alias SwapifyApi.Accounts
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Notifications.JobErrorNotification
  alias SwapifyApi.Notifications.JobUpdateNotification
  alias SwapifyApi.Operations
  alias SwapifyApi.Operations.TaskEventHandler
  alias SwapifyApi.Operations.TransferRepo
  alias SwapifyApi.Utils
  alias SwapifyApiWeb.JobUpdateChannel

  require Logger

  use Oban.Worker,
    queue: :transfer_tracks,
    max_attempts: 6

  use TaskEventHandler, job_module: Utils.get_module_name(__MODULE__)

  @spotify_add_limit 50

  defp handle_error({:error, error}) when is_atom(error), do: {:error, error}

  defp handle_error({:error, %{details: %{status: 427}}}), do: {:error, :rate_limit}

  defp on_job_success(user_id, transfer_id) do
    Task.Supervisor.start_child(Task.Supervisor, fn ->
      with {:ok, %{username: username}} <- Accounts.get_by_id(user_id),
           {:ok, transfer} <- Operations.get_transfer_infos(transfer_id) do
        SwapifyApi.Emails.transfer_done(transfer.email, username,
          app_url: Application.fetch_env!(:swapify_api, :app_url),
          username: username,
          source_name: PlatformConnection.get_name(transfer.source),
          destination_name: PlatformConnection.get_name(transfer.destination)
        )
      end
    end)
  end

  defp on_job_failed(%{
         "user_id" => user_id,
         "job_id" => job_id,
         "transfer_id" => transfer_id
       }) do
    Task.Supervisor.start_child(Task.Supervisor, fn ->
      JobUpdateChannel.broadcast_job_progress(
        user_id,
        JobErrorNotification.new_transfer_tracks_error(transfer_id)
      )

      with {:ok, _} <- Operations.update_job_status(job_id, :error),
           {:ok, %{username: username}} <- Accounts.get_by_id(user_id),
           {:ok, transfer} <- Operations.get_transfer_infos(transfer_id) do
        SwapifyApi.Emails.transfer_error(transfer.email, username,
          app_url: Application.fetch_env!(:swapify_api, :app_url),
          username: username,
          source_name: PlatformConnection.get_name(transfer.source),
          destination_name: PlatformConnection.get_name(transfer.destination)
        )
      end
    end)
  end

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
        with {:ok, _} <- Operations.update_job_status(job_id, :done),
             {:ok, _} <- on_job_success(transfer_id, job_id) do
          {:ok,
           notification:
             JobUpdateNotification.new_transfer_tracks_update(
               transfer_id,
               "spotify",
               offset,
               :done
             )}
        end

      {:ok, tracks} ->
        with {:ok, _} <-
               Spotify.add_tracks_to_library(
                 access_token,
                 Enum.map(tracks, fn mt -> mt.platform_id end)
               ),
             {:ok, _} <-
               Map.merge(args, %{
                 "offset" => offset + @spotify_add_limit
               })
               |> __MODULE__.new()
               |> Oban.insert() do
          {:ok,
           notification:
             JobUpdateNotification.new_transfer_tracks_update(
               transfer_id,
               "spotify",
               offset,
               :started
             )}
        else
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
  end

  def transfer(
        "applemusic",
        %{
          "user_id" => user_id,
          "offset" => offset,
          "access_token" => access_token,
          "transfer_id" => transfer_id,
          "job_id" => job_id,
          "is_library" => true
        } = args
      ) do
    case TransferRepo.get_matched_track_by_index(transfer_id, offset) do
      {:error, %ErrorMessage{code: :not_found}} ->
        with {:ok, _} <- Operations.update_job_status(job_id, :done),
             {:ok, _} <- on_job_success(transfer_id, job_id) do
          {:ok,
           notification:
             JobUpdateNotification.new_transfer_tracks_update(
               transfer_id,
               "applemusic",
               offset,
               :done
             )}
        end

      {:ok, matched_track} ->
        developer_token = AppleMusicTokenWorker.get()

        case AppleMusic.add_track_to_library(
               developer_token,
               access_token,
               matched_track.platform_id
             ) do
          {:ok, _} ->
            with {:ok, _} <-
                   Map.merge(args, %{
                     "offset" => offset + 1
                   })
                   |> __MODULE__.new()
                   |> Oban.insert() do
              {:ok,
               notification:
                 JobUpdateNotification.new_transfer_tracks_update(
                   transfer_id,
                   "applemusic",
                   offset,
                   :started
                 )}
            end

          {:error, %{details: %{status: 401}}} ->
            Accounts.disable_partner_integration(user_id, :applemusic)
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
    on_job_failed(job_args)

    Logger.info("TransferTracks job cancelled",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )

    Operations.update_job_status(job_args["job_id"], :error)
  end

  handle :success do
    {:ok, notification: notification} = result

    JobUpdateChannel.broadcast_job_progress(job_args["user_id"], notification)

    Logger.info("TransferTracks job finished",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
  end

  handle :failure do
    on_job_failed(job_args)

    Logger.info("TransferTracks job failure(max attempt exceeded)",
      user_id: job_args["user_id"],
      service: job_args["platform_name"]
    )
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
