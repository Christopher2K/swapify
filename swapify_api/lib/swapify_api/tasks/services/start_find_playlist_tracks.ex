defmodule SwapifyApi.Tasks.Services.StartFindPlaylistTracks do
  alias SwapifyApi.Tasks.Services.UpdateJobStatus
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Tasks.JobRepo
  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob
  alias SwapifyApi.Accounts.PlatformConnectionRepo

  @spec call(String.t(), PlatformConnection.platform_name(), String.t(), String.t()) ::
          {:ok, Job.t()} | {:error, atom()}
  def call(user_id, target_platform, playlist_id, transfer_id) do
    with {:ok, pc} <-
           PlatformConnectionRepo.get_by_user_id_and_platform(user_id, target_platform),
         job_args <-
           FindPlaylistTracksJob.args(
             playlist_id,
             target_platform,
             transfer_id,
             user_id,
             pc.access_token,
             pc.refresh_token
           ),
         {:ok, db_job} <-
           JobRepo.create(%{
             "name" => "search_track",
             "status" => :started,
             "user_id" => user_id,
             "oban_job_args" =>
               Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
           }) do
      case Map.merge(job_args, %{"job_id" => db_job.id})
           |> FindPlaylistTracksJob.new()
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
