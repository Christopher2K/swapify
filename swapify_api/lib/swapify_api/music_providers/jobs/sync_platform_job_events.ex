defmodule SwapifyApi.MusicProviders.Jobs.SyncPlatformJobEvents do
  @moduledoc """
  Events for the sync_platform job
  """
  require Logger

  def handle_event(
        [:oban, :job, :start],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncPlatformJob", args: args}},
        _
      ) do
    Logger.info("Sync Platform job started",
      user_id: args["user_id"],
      service: args["service"]
    )

  end

  def handle_event(
        [:oban, :job, :stop],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncPlatformJob", args: args}},
        _
      ) do
    Logger.info("Sync Platform job finished",
      user_id: args["user_id"],
      service: args["service"]
    )

  end

  def handle_event(
        [:oban, :job, :exception],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncPlatformJob", args: args}},
        _
      ) do

    Logger.info("Sync Library job cancelled",
      user_id: args["user_id"],
      service: args["service"]
    )
  end

  def handle_event(
        [:oban, :engine, :cancel_job, :start],
        _,
        %{job: %{worker: "SwapifyApi.MusicProviders.Jobs.SyncPlatformJob", args: args}},
        _
      ) do

    Logger.error("Sync Library job error",
      user_id: args["user_id"],
      service: args["service"]
    )
  end

  def handle_event(_, _, _, _), do: :ok
end
