defmodule SwapifyApi.Operations do
  @moduledoc """
  Task contexts
  """
  alias SwapifyApi.Repo
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob
  alias SwapifyApi.MusicProviders.Jobs.TransferTracksJob
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.Operations.Job
  alias SwapifyApi.Operations.JobRepo
  alias SwapifyApi.Operations.Transfer
  alias SwapifyApi.Operations.TransferRepo

  @doc "Update a job status and timestamps if needed"
  @spec update_job_status(String.t(), Job.job_status()) ::
          {:ok, Job.t()} | {:error, ErrorMessage.t()} | {:error, Ecto.Changeset.t()}

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

  @doc """
  Start a playlist transfer first step: matching job
  Returns a map %{transfer: Transfer.t(), job: Job.t()}
  """
  @spec start_playlist_transfer_matching_step(
          String.t(),
          String.t(),
          PlatformConnection.platform_name()
        ) ::
          {:ok, map()} | {:error, ErrorMessage.t()} | {:error, Ecto.Changeset.t()}
  def start_playlist_transfer_matching_step(
        user_id,
        playlist_id,
        destination
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:playlist, fn _, _ -> PlaylistRepo.get_by_id(playlist_id) end)
    |> Ecto.Multi.run(:pc, fn _, _ ->
      PlatformConnectionRepo.get_by_user_id_and_platform(user_id, destination)
    end)
    |> Ecto.Multi.run(:transfer, fn _, %{playlist: playlist} ->
      TransferRepo.create(%{
        "source_playlist_id" => playlist.id,
        "destination" => destination,
        "user_id" => user_id
      })
    end)
    |> Ecto.Multi.run(:job_args, fn _, %{transfer: transfer, pc: pc, playlist: playlist} ->
      {:ok,
       FindPlaylistTracksJob.args(
         playlist.id,
         destination,
         transfer.id,
         user_id,
         pc.access_token,
         pc.refresh_token
       )}
    end)
    |> Ecto.Multi.run(:job, fn _, %{job_args: job_args} ->
      JobRepo.create(%{
        "name" => "search_tracks",
        "status" => :started,
        "user_id" => user_id,
        "oban_job_args" =>
          Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
      })
    end)
    |> Ecto.Multi.run(:transfer_update, fn _, %{transfer: transfer, job: job} ->
      TransferRepo.update(transfer, %{"matching_step_job_id" => job.id})
    end)
    |> Ecto.Multi.run(:oban, fn _, %{job: job, job_args: job_args} ->
      Map.merge(job_args, %{"job_id" => job.id})
      |> FindPlaylistTracksJob.new()
      |> Oban.insert()
      |> SwapifyApi.Utils.check_oban_insertion_result()
    end)
    |> Ecto.Multi.run(:result, fn _, %{job: job, transfer_update: transfer} ->
      {:ok,
       %{
         transfer:
           Repo.preload(transfer, [:matching_step_job, :transfer_step_job, :source_playlist]),
         job: job
       }}
    end)
    |> Repo.transaction()
    |> SwapifyApi.Utils.handle_transaction_result()
  end

  @doc """
  Start a playlist transfer transfer step: transfer job
  """
  @spec start_playlist_transfer_transfer_step(String.t(), String.t()) ::
          {:ok, %{transfer: Transfer, job: Job.t()}}
          | {:error, ErrorMessage.t()}
          | {:error, Ecto.Changeset.t()}
  def start_playlist_transfer_transfer_step(user_id, transfer_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:transfer, fn _, _ ->
      TransferRepo.get_transfer_by_step_and_id(transfer_id, :matching,
        includes: [:source_playlist]
      )
    end)
    |> Ecto.Multi.run(:pc, fn _, %{transfer: transfer} ->
      PlatformConnectionRepo.get_by_user_id_and_platform(user_id, transfer.destination)
    end)
    |> Ecto.Multi.run(:job_args, fn _, %{transfer: transfer, pc: pc} ->
      {:ok,
       TransferTracksJob.args(
         user_id,
         transfer.id,
         transfer.destination,
         user_id == transfer.source_playlist.platform_id,
         pc.access_token,
         pc.refresh_token
       )}
    end)
    |> Ecto.Multi.run(:job, fn _, %{job_args: job_args} ->
      JobRepo.create(%{
        "name" => "transfer_tracks",
        "status" => :started,
        "user_id" => user_id,
        "oban_job_args" =>
          Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
      })
    end)
    |> Ecto.Multi.run(:transfer_update, fn _, %{job: job, transfer: transfer} ->
      TransferRepo.update(transfer, %{"transfer_step_job_id" => job.id})
    end)
    |> Ecto.Multi.run(:oban, fn _, %{job_args: job_args, job: job} ->
      Map.merge(job_args, %{"job_id" => job.id})
      |> TransferTracksJob.new()
      |> Oban.insert()
      |> SwapifyApi.Utils.check_oban_insertion_result()
    end)
    |> Ecto.Multi.run(:result, fn _, %{job: job, transfer_update: transfer} ->
      {:ok,
       %{
         transfer:
           Repo.preload(transfer, [:matching_step_job, :transfer_step_job, :source_playlist]),
         job: job
       }}
    end)
    |> Repo.transaction()
    |> SwapifyApi.Utils.handle_transaction_result()
  end

  @doc "List all transfers for a given user"
  @spec list_transfers_by_user_id(String.t()) :: {:ok, list(Transfer.t())}
  def list_transfers_by_user_id(user_id), do: {:ok, TransferRepo.list_by_user_id(user_id)}

  @doc "Get a transfer by its ID"
  @spec get_transfer_by_id(String.t()) :: {:ok, Transfer.t()} | {:error, ErrorMessage.t()}
  def get_transfer_by_id(transfer_id), do: TransferRepo.get_by_id(transfer_id)

  @doc "Get metadata about a transfer without fetching the tracks"
  @spec get_transfer_infos(String.t()) ::
          {:ok, TransferRepo.transfer_infos()} | {:error, ErrorMessage.t()}
  def get_transfer_infos(transfer_id), do: TransferRepo.get_transfer_infos(transfer_id)

  @doc "Cancel a transfer when it's in the `waiting for confirmation` state"
  @spec cancel_transfer(String.t(), String.t()) ::
          {:ok, Transfer.t()} | {:error, Ecto.Changeset.t()} | {:error, ErrorMessage.t()}
  def cancel_transfer(user_id, transfer_id) do
    with {:ok, transfer} <- TransferRepo.get_user_transfer_by_id(user_id, transfer_id) do
      if Transfer.can_be_cancelled?(transfer) do
        with {:ok, _} <- update_job_status(transfer.matching_step_job_id, :canceled) do
          TransferRepo.get_user_transfer_by_id(user_id, transfer_id)
        end
      else
        {:error,
         ErrorMessage.bad_request("The transfer cannot be cancelled in its current state.")}
      end
    end
  end

  def count_transfers(), do: TransferRepo.count()
end
