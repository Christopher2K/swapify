defmodule SwapifyApi.Tasks do
  @moduledoc """
  Task contexts
  """
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob
  alias SwapifyApi.MusicProviders.Jobs.TransferTracksJob
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.Tasks.JobRepo
  alias SwapifyApi.Tasks.Transfer
  alias SwapifyApi.Tasks.TransferRepo

  @doc """
  Handle Oban insertion error when a domain job is involved
  """
  @spec handle_oban_insertion_error(any(), Job.t(), any()) ::
          {:ok, Job.t()} | SwapifyApi.Errors.t()
  def handle_oban_insertion_error(result, %Job{} = job, on_error \\ fn _ -> :ok end) do
    case result do
      {:ok, %{id: nil, conflict?: true}} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        on_error.()

        SwapifyApi.Errors.failed_to_acquire_lock()

      {:ok, %{conflict?: true}} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        on_error.()

        SwapifyApi.Errors.job_already_exists()

      {:ok, _} ->
        {:ok, job}

      {:error, _} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        on_error.()

        SwapifyApi.Errors.oban_error()
    end
  end

  @spec start_find_playlist_tracks(
          String.t(),
          PlatformConnection.platform_name(),
          String.t(),
          String.t()
        ) ::
          {:ok, Job.t()} | SwapifyApi.Errors.t()
  defp start_find_playlist_tracks(user_id, target_platform, playlist_id, transfer_id) do
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

  @doc """
  Start a playlist transfer first step: matching job
  """
  @spec start_playlist_transfer_matching_step(
          String.t(),
          String.t(),
          PlatformConnection.platform_name()
        ) ::
          {:ok, Job.t()} | SwapifyApi.Errors.t()
  def start_playlist_transfer_matching_step(
        user_id,
        playlist_id,
        destination
      ) do
    with {:ok, playlist} <- PlaylistRepo.get_by_id(playlist_id),
         {:ok, transfer} <-
           TransferRepo.create(%{
             "source_playlist_id" => playlist.id,
             "destination" => destination,
             "user_id" => user_id
           }),
         {:ok, job} <- start_find_playlist_tracks(user_id, destination, playlist.id, transfer.id) do
      TransferRepo.update(transfer, %{"matching_step_job_id" => job.id})
    end
  end

  @doc """
  Start a playlist transfer transfer step: transfer job
  """
  @spec start_playlist_transfer_transfer_step(String.t(), String.t()) ::
          {:ok, Job.t()} | SwapifyApi.Errors.t()
  def start_playlist_transfer_transfer_step(user_id, transfer_id) do
    with {:ok, %Transfer{source_playlist: playlist} = transfer} <-
           TransferRepo.get_transfer_by_step_and_id(transfer_id, :matching,
             includes: [:source_playlist]
           ),
         {:ok, pc} <-
           PlatformConnectionRepo.get_by_user_id_and_platform(user_id, transfer.destination),
         job_args <-
           TransferTracksJob.args(
             user_id,
             transfer_id,
             transfer.destination,
             user_id == playlist.platform_id,
             pc.access_token,
             pc.refresh_token
           ),
         {:ok, db_job} <-
           JobRepo.create(%{
             "name" => "transfer_tracks",
             "status" => :started,
             "user_id" => user_id,
             "oban_job_args" =>
               Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
           }),
         {:ok, _} <- TransferRepo.update(transfer, %{"transfer_step_job_id" => db_job.id}) do
      Map.merge(job_args, %{"job_id" => db_job.id})
      |> TransferTracksJob.new()
      |> Oban.insert()
      |> handle_oban_insertion_error(db_job, fn _ ->
        TransferRepo.update(transfer, %{"transfer_step_job_id" => nil})
      end)
    end
  end
end
