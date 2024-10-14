defmodule SwapifyApi.Tasks do
  @moduledoc """
  Task contexts
  """
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob
  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.Tasks.JobRepo

  @doc """
  Handle Oban insertion error when a domain job is involved
  """
  @spec handle_oban_insertion_error(any(), Job.t()) :: {:ok, Job.t()} | SwapifyApi.Errors.t()
  def handle_oban_insertion_error(result, %Job{} = job) do
    case result do
      {:ok, %{id: nil, conflict?: true}} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        SwapifyApi.Errors.failed_to_acquire_lock()

      {:ok, %{conflict?: true}} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        SwapifyApi.Errors.job_already_exists()

      {:ok, _} ->
        {:ok, job}

      {:error, _} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        SwapifyApi.Errors.oban_error()
    end
  end

  @doc """
  Start a find playlist tracks job - the first step of a transfer
  """
  @spec start_find_playlist_tracks(
          String.t(),
          PlatformConnection.platform_name(),
          String.t(),
          String.t()
        ) ::
          {:ok, Job.t()} | SwapifyApi.Errors.t()
  def start_find_playlist_tracks(user_id, target_platform, playlist_id, transfer_id) do
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
             "name" => "search_tracks",
             "status" => :started,
             "user_id" => user_id,
             "oban_job_args" =>
               Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
           }) do
      Map.merge(job_args, %{"job_id" => db_job.id})
      |> FindPlaylistTracksJob.new()
      |> Oban.insert()
      |> handle_oban_insertion_error(db_job)
    end
  end
end
