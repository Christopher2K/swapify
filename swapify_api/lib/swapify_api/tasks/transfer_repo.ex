defmodule SwapifyApi.Tasks.TransferRepo do
  @doc "Transfer table repository"
  import Ecto.Query

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
end
