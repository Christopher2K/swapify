defmodule SwapifyApi.MusicProviders.Jobs.SyncPlatformJobEvents do
  @moduledoc """
  Events for the sync_platform job
  """
  require Logger
  alias SwapifyApi.Tasks.Services.UpdateJobStatus

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
        %{
          job:
            %Oban.Job{worker: "SwapifyApi.MusicProviders.Jobs.SyncPlatformJob", args: args} = job
        },
        _
      ) do
    if job.attempt == job.max_attempts do
      Logger.info("Sync Library job cancelled",
        user_id: args["user_id"],
        service: args["service"]
      )

      UpdateJobStatus.call(args["job_id"], :error)
    else
      Logger.info("Sync Library job error",
        user_id: args["user_id"],
        service: args["service"]
      )
    end
  end

  def handle_event(_, _, _, _), do: :ok
end
