defmodule SwapifyApi.MusicProviders.Services.StartLibrarySync do
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Tasks.Services.UpdateJobStatus
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.MusicProviders.Jobs.SyncLibraryJob
  alias SwapifyApi.Tasks.JobRepo
  alias SwapifyApi.Tasks.Job

  @spec call(String.t(), PlatformConnection.platform_name()) ::
          {:ok, Job.t()} | {:error, :failed_to_acquire_lock | :job_already_exists | :oban_error}
  def call(user_id, platform_name) do
    with {:ok, playlist} <- PlaylistRepo.get_user_library(user_id, platform_name),
         {:ok, pc} <- PlatformConnectionRepo.get_by_user_id_and_platform(user_id, platform_name),
         job_args <-
           SyncLibraryJob.args(
             playlist.id,
             platform_name,
             user_id,
             pc.access_token,
             pc.refresh_token
           ),
         {:ok, db_job} <-
           JobRepo.create(%{
             "name" => "sync_library",
             "status" => :started,
             "user_id" => user_id,
             "oban_job_args" =>
               Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
           }),
         {:ok, _} <- PlaylistRepo.update_status(playlist.id, :syncing) do
      case Map.merge(job_args, %{"job_id" => db_job.id})
           |> SyncLibraryJob.new()
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
          {:error, :oban_error}
      end
    end
  end
end
