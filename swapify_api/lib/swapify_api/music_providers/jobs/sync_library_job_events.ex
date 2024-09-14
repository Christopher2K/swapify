defmodule SwapifyApi.MusicProviders.Jobs.SyncLibraryJobEvents do
  @moduledoc """
  Events for the sync_library_job
  """
  require Logger

  alias SwapifyApi.Notifications.JobErrorNotification
  alias SwapifyApi.MusicProviders.Services.MarkPlaylistTransferAsFailed
  alias SwapifyApiWeb.PlaylistSyncChannel
  alias SwapifyApi.Tasks.Services.UpdateJobStatus

  def handle_event(
        [:oban, :job, :start],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob", args: args}},
        _
      ) do
    Logger.info("Sync Library job started",
      user_id: args["user_id"],
      service: args["service"]
    )
  end

  def handle_event(
        [:oban, :job, :stop],
        _,
        %{
          job:
            %Oban.Job{
              worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob",
              args: args
            } = job,
          state: state,
          result: result
        },
        _
      ) do
    case state do
      :cancelled ->
        handle_playlist_sync_error(job)

        Logger.info("Sync Library job cancelled",
          user_id: job.args["user_id"],
          service: job.args["service"]
        )

      :success ->
        {:ok, notification: notification} = result

        PlaylistSyncChannel.broadcast_sync_progress(
          args["user_id"],
          notification
        )

        Logger.info("Sync Library job finished",
          user_id: args["user_id"],
          service: args["service"]
        )

      _ ->
        :ok
    end
  end

  def handle_event(
        [:oban, :job, :exception],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob"} = job},
        _
      ) do
    if job.attempt == job.max_attempts do
      handle_playlist_sync_error(job)

      Logger.info("Sync Library job error (max attempt exceeded)",
        user_id: job.args["user_id"],
        service: job.args["service"]
      )
    else
      Logger.info("Sync Library job error",
        user_id: job.args["user_id"],
        service: job.args["service"]
      )
    end
  end

  def handle_event(_, _, _, _), do: :ok

  defp handle_playlist_sync_error(%{
         args: %{
           "user_id" => user_id,
           "playlist_id" => playlist_id,
           "job_id" => job_id,
           "platform_name" => platform_name
         }
       }) do
    PlaylistSyncChannel.broadcast_sync_progress(
      user_id,
      JobErrorNotification.new_library_sync_error(
        playlist_id,
        platform_name
      )
    )

    Task.await_many([
      Task.async(fn ->
        MarkPlaylistTransferAsFailed.call(playlist_id)
      end),
      Task.async(fn ->
        UpdateJobStatus.call(job_id, :error)
      end)
    ])
  end
end
