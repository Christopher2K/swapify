defmodule SwapifyApi.Tasks.Services.StartPlaylistTransferTransferStep do
  @moduledoc """
  """
  alias SwapifyApi.Tasks.JobRepo
  alias SwapifyApi.MusicProviders.Jobs.TransferTracksJob
  alias SwapifyApi.Tasks.Transfer
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.Tasks.TransferRepo
  alias SwapifyApi.Tasks.Services.UpdateJobStatus

  def call(user_id, transfer_id) do
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
      case Map.merge(job_args, %{"job_id" => db_job.id})
           |> TransferTracksJob.new()
           |> Oban.insert() do
        {:ok, %{id: nil, conflict?: true}} ->
          UpdateJobStatus.call(db_job.id, :error)
          TransferRepo.update(transfer, %{"transfer_step_job_id" => nil})
          {:error, :failed_to_acquire_lock}

        {:ok, %{conflict?: true}} ->
          UpdateJobStatus.call(db_job.id, :error)
          TransferRepo.update(transfer, %{"transfer_step_job_id" => nil})
          {:error, :job_already_exists}

        {:ok, _} ->
          {:ok, db_job}

        {:error, _} ->
          UpdateJobStatus.call(db_job.id, :error)
          TransferRepo.update(transfer, %{"transfer_step_job_id" => nil})
          {:error, :oban_error}
      end
    end
  end
end
