defmodule SwapifyApi.MusicProviders.Jobs.SyncLibraryJobEvents do
  @moduledoc """
  Events for the sync_library_job
  """
  require Logger

  alias SwapifyApi.MusicProviders.Services.MarkPlaylistTransferAsFailed
  alias SwapifyApi.MusicProviders.Jobs.SyncLibraryJob
  alias SwapifyApiWeb.PlaylistSyncChannel

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

    PlaylistSyncChannel.broadcast_sync_progress(
      args["user_id"],
      SyncLibraryJob.to_notification(
        args,
        if(args["tracks_count"] == ["synced_tracks_count"], do: :synced, else: :syncing)
      )
    )
  end

  def handle_event(
        [:oban, :job, :stop],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob", args: args}},
        _
      ) do
    Logger.info("Sync Library job finished",
      user_id: args["user_id"],
      service: args["service"]
    )

    PlaylistSyncChannel.broadcast_sync_progress(
      args["user_id"],
      SyncLibraryJob.to_notification(
        args,
        if(args["tracks_count"] == ["synced_tracks_count"], do: :synced, else: :syncing)
      )
    )
  end

  def handle_event(
        [:oban, :job, :exception],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob", args: args} = job},
        _
      ) do
    handle_playlist_sync_error(job)

    Logger.info("Sync Library job cancelled",
      user_id: job.args["user_id"],
      service: job.args["service"]
    )

    PlaylistSyncChannel.broadcast_sync_progress(
      args["user_id"],
      SyncLibraryJob.to_notification(
        args,
        :error
      )
    )
  end

  def handle_event(
        [:oban, :engine, :cancel_job, :start],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob", args: args} = job},
        _
      ) do
    handle_playlist_sync_error(job)

    Logger.error("Sync Library job error",
      user_id: args["user_id"],
      service: args["service"]
    )

    PlaylistSyncChannel.broadcast_sync_progress(
      args["user_id"],
      SyncLibraryJob.to_notification(
        args,
        :error
      )
    )
  end

  def handle_event(_, _, _, _), do: :ok

  defp handle_playlist_sync_error(%{args: %{"playlist_id" => playlist_id}}) do
    if playlist_id do
      MarkPlaylistTransferAsFailed.call(playlist_id)
    end
  end
end
