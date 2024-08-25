defmodule SwapifyApi.MusicProviders.Jobs.SyncLibraryJobEvents do
  @moduledoc """
  Events for the sync_library_job
  """
  require Logger

  alias SwapifyApi.MusicProviders.Services.MarkPlaylistTransferAsFailed

  def handle_event(
        [:oban, :job, :start],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob"} = job},
        _
      ) do
    Logger.info("Sync Library job started",
      user_id: job.args["user_id"],
      service: job.args["service"]
    )
  end

  def handle_event(
        [:oban, :job, :stop],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob"} = job},
        _
      ) do
    Logger.info("Sync Library job finished",
      user_id: job.args["user_id"],
      service: job.args["service"]
    )
  end

  def handle_event(
        [:oban, :job, :exception],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob"} = job},
        _
      ) do
    handle_playlist_sync_error(job)

    Logger.info("Sync Library job cancelled",
      user_id: job.args["user_id"],
      service: job.args["service"]
    )
  end

  def handle_event(
        [:oban, :engine, :cancel_job, :start],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncLibraryJob"} = job},
        _
      ) do
    handle_playlist_sync_error(job)

    Logger.error("Sync Library job error",
      user_id: job.args["user_id"],
      service: job.args["service"]
    )
  end

  def handle_event(_, _, _, _), do: :ok

  defp handle_playlist_sync_error(%{args: %{"playlist_id" => playlist_id}}) do
    if playlist_id do
      MarkPlaylistTransferAsFailed.call(playlist_id)
    end
  end
end
