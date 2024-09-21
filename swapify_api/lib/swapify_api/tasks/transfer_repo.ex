defmodule SwapifyApi.Tasks.TransferRepo do
  @doc "Transfer table repository"
  import Ecto.Query

  alias SwapifyApi.Utils
  alias SwapifyApi.Tasks.MatchedTrack
  alias SwapifyApi.Repo
  alias SwapifyApi.Tasks.Transfer

  @spec create(map()) :: {:ok, Transfer.t()} | {:error, Ecto.Changeset.t()}
  def create(args),
    do:
      %Transfer{}
      |> Transfer.changeset(args)
      |> Repo.insert()

  @spec add_matched_tracks(String.t(), list(MatchedTrack.t())) ::
          {:ok, nil} | {:error, :not_found}
  def add_matched_tracks(transfer_id, matched_tracks) do
    from(t in Transfer,
      where: [id: ^transfer_id],
      update: [
        set: [
          matched_tracks: fragment("? || ?", t.matched_tracks, ^matched_tracks)
        ]
      ]
    )
    |> Repo.update_all([])
    |> case do
      {1, _} ->
        {:ok, nil}

      {_, _} ->
        {:error, :not_found}
    end
  end

  @spec update(Transfer.t(), map()) :: {:ok, Transfer.t()} | {:error, Ecto.Changeset.t()}
  def update(transfer, args) do
    transfer
    |> Transfer.changeset(args)
    |> Repo.update(returning: true)
  end

  @spec get_transfer_by_step_and_id(String.t(), Transfer.transfer_step()) ::
          {:ok, Transfer.t()} | {:error, :not_found}

  def get_transfer_by_step_and_id(transfer_id, :matching) do
    Transfer.queryable()
    |> Transfer.include(:matching_job)
    |> Transfer.filter_by(:id, transfer_id)
    |> Transfer.step(:matching, :done)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  def get_transfer_by_step_and_id(transfer_id, :pre_transfer) do
    Transfer.queryable()
    |> Transfer.include(:matching_job)
    |> Transfer.include(:pre_transfer_job)
    |> Transfer.filter_by(:id, transfer_id)
    |> Transfer.step(:pre_transfer, :done)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  def get_transfer_by_step_and_id(transfer_id, :transfer) do
    Transfer.queryable()
    |> Transfer.include(:matching_job)
    |> Transfer.include(:pre_transfer_job)
    |> Transfer.include(:transfer_job)
    |> Transfer.filter_by(:id, transfer_id)
    |> Transfer.step(:transfer, :done)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end
end
