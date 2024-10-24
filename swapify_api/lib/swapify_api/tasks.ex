defmodule SwapifyApi.Tasks do
  @moduledoc """
  Task contexts
  """
  alias SwapifyApi.Repo
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

  @doc "Update a job status and timestamps if needed"
  @spec update_job_status(String.t(), Job.job_status()) :: {:ok, Job.t()} | SwapifyApi.Errors.t()

  def update_job_status(job_id, new_status) when new_status == :done do
    JobRepo.update(job_id, %{
      "status" => new_status,
      "done_at" => DateTime.utc_now(),
      "cancelled_at" => nil
    })
  end

  def update_job_status(job_id, new_status) when new_status in [:canceled, :error] do
    JobRepo.update(job_id, %{
      "status" => new_status,
      "canceled_at" => DateTime.utc_now(),
      "done_at" => nil
    })
  end

  def update_job_status(job_id, new_status),
    do: JobRepo.update(job_id, %{"status" => new_status})

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
          {:ok, Transfer.t()} | SwapifyApi.Errors.t()
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
         {:ok, job} <- start_find_playlist_tracks(user_id, destination, playlist.id, transfer.id),
         {:ok, transfer} <- TransferRepo.update(transfer, %{"matching_step_job_id" => job.id}) do
      {:ok, Repo.preload(transfer, [:matching_step_job, :transfer_step_job, :source_playlist])}
    end
  end

  defp start_transfer_playlist_tracks(user_id, transfer) do
    with {:ok, pc} <-
           PlatformConnectionRepo.get_by_user_id_and_platform(user_id, transfer.destination),
         job_args <-
           TransferTracksJob.args(
             user_id,
             transfer.id,
             transfer.destination,
             user_id == transfer.source_playlist.platform_id,
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
           }) do
      Map.merge(job_args, %{"job_id" => db_job.id})
      |> TransferTracksJob.new()
      |> Oban.insert()
      |> handle_oban_insertion_error(db_job)
    end
  end

  @doc """
  Start a playlist transfer transfer step: transfer job
  """
  @spec start_playlist_transfer_transfer_step(String.t(), String.t()) ::
          {:ok, Job.t()} | SwapifyApi.Errors.t()
  def start_playlist_transfer_transfer_step(user_id, transfer_id) do
    with {:ok, transfer} <-
           TransferRepo.get_transfer_by_step_and_id(transfer_id, :matching,
             includes: [:source_playlist]
           ),
         {:ok, db_job} <- start_transfer_playlist_tracks(user_id, transfer),
         {:ok, _} <- TransferRepo.update(transfer, %{"transfer_step_job_id" => db_job.id}) do
      {:ok, Repo.preload(transfer, [:matching_step_job, :transfer_step_job, :source_playlist])}
    end
  end

  @doc "List all transfers for a given user"
  @spec list_transfers_by_user_id(String.t()) :: {:ok, list(Transfer.t())}
  def list_transfers_by_user_id(user_id), do: {:ok, TransferRepo.list_by_user_id(user_id)}

  @doc "Cancel a transfer when it's in the `waiting for confirmation` state"
  @spec cancel_transfer(String.t(), String.t()) ::
          {:ok, Transfer.t()} | {:error, Ecto.Changeset.t()}
  def cancel_transfer(user_id, transfer_id) do
    # 2. Check for domain invariants
    # 3. If possible, cancel the transfer
    with {:ok, transfer} <- TransferRepo.get_user_transfer_by_id(user_id, transfer_id) do
      if Transfer.can_be_cancelled?(transfer) do
        with {:ok, _} <- update_job_status(transfer.matching_step_job_id, :canceled) do
          TransferRepo.get_user_transfer_by_id(user_id, transfer_id)
        end
      else
        SwapifyApi.Errors.transfer_cancel_error()
      end
    end
  end
end
