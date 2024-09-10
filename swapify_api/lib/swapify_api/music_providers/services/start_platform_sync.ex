defmodule SwapifyApi.MusicProviders.Services.StartSyncPlatform do
  require Logger

  alias SwapifyApi.Tasks.Services.UpdateJobStatus
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.MusicProviders.Jobs.SyncPlatformJob
  alias SwapifyApi.Tasks.JobRepo

  def call(user_id, platform_name) do
    with {:ok, pc} <- PlatformConnectionRepo.get_by_user_id_and_platform(user_id, platform_name),
         job_args <-
           SyncPlatformJob.args(platform_name, user_id, pc.access_token, pc.refresh_token, true),
         {:ok, db_job} <-
           JobRepo.create(%{
             "name" => "sync_platform",
             "status" => :started,
             "user_id" => user_id,
             "oban_job_args" =>
               Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
           }) do
      case Map.merge(job_args, %{"job_id" => db_job.id})
           |> SyncPlatformJob.new()
           |> Oban.insert() do
        {:ok, %{id: nil, conflict?: true}} ->
          UpdateJobStatus.call(db_job.id, :error)
          {:error, :failed_to_acquire_lock}

        {:ok, %{conflict?: true}} ->
          UpdateJobStatus.call(db_job.id, :error)
          {:error, :job_already_exists}

        {:ok, _} ->
          {:ok, db_job}

        {:error, _} ->
          UpdateJobStatus.call(db_job.id, :error)
          {:error}
      end
    end
  end
end
