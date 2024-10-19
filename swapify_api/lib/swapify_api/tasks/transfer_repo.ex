defmodule SwapifyApi.Tasks.TransferRepo do
  @doc "Transfer table repository"
  import Ecto.Query

  alias SwapifyApi.MusicProviders.Track
  alias SwapifyApi.Repo
  alias SwapifyApi.Tasks.MatchedTrack
  alias SwapifyApi.Tasks.Transfer
  alias SwapifyApi.Utils

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

  @spec add_not_found_tracks(String.t(), list(Track.t())) :: {:ok, nil} | {:error, :not_found}
  def add_not_found_tracks(transfer_id, tracks) do
    Transfer.queryable()
    |> Transfer.filter_by(:id, transfer_id)
    |> Ecto.Query.update([transfer: t],
      set: [
        not_found_tracks: fragment("? || ?", t.not_found_tracks, ^tracks)
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

  @spec get_transfer_by_step_and_id(String.t(), Transfer.transfer_step(), Keyword.t()) ::
          {:ok, Transfer.t()} | {:error, :not_found}

  def get_transfer_by_step_and_id(transfer_id, step, opts \\ [])

  def get_transfer_by_step_and_id(transfer_id, :matching, opts) do
    Transfer.queryable()
    |> Transfer.include(:matching_job)
    |> Transfer.filter_by(:id, transfer_id)
    |> Transfer.step(:matching, :done)
    |> handle_tranfer_inclusions(Keyword.get(opts, :includes, []))
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  def get_transfer_by_step_and_id(transfer_id, :transfer, opts) do
    Transfer.queryable()
    |> Transfer.include(:matching_job)
    |> Transfer.include(:transfer_job)
    |> Transfer.filter_by(:id, transfer_id)
    |> Transfer.step(:transfer, :done)
    |> handle_tranfer_inclusions(Keyword.get(opts, :includes, []))
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  defp handle_tranfer_inclusions(query, includes),
    do:
      includes
      |> Enum.reduce(query, fn include, q ->
        case include do
          :source_playlist -> preload(q, [], [:source_playlist])
          _ -> q
        end
      end)

  @doc """
  Get a specific track by its index
  """
  @spec get_matched_track_by_index(String.t(), pos_integer()) ::
          {:ok, MatchedTrack.t()} | {:error, :not_found}
  def get_matched_track_by_index(transfer_id, index) do
    Transfer.queryable()
    |> Transfer.filter_by(:id, transfer_id)
    |> select([transfer: t], fragment("?[?]", t.matched_tracks, ^Integer.to_string(index)))
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      track ->
        {:ok, Map.merge(%MatchedTrack{}, Recase.Enumerable.atomize_keys(track))}
    end
  end

  @doc """
  Get a specific subset of matched tracks
  """
  @spec get_matched_tracks(String.t(), pos_integer(), pos_integer()) ::
          {:ok, list(MatchedTrack.t())}
  def get_matched_tracks(transfer_id, offset, limit) do
    {:ok,
     Transfer.queryable()
     |> Transfer.filter_by(:id, transfer_id)
     |> select([transfer: t], fragment("jsonb_array_elements(?)", t.matched_tracks))
     |> offset(^offset)
     |> limit(^limit)
     |> Repo.all()
     |> Enum.map(fn track ->
       Map.merge(%MatchedTrack{}, Recase.Enumerable.atomize_keys(track))
     end)}
  end

  @doc "List all transfers for a given user"
  @spec list_by_user_id(String.t()) :: {:ok, list(Transfer.t())}
  def list_by_user_id(user_id) do
    Transfer.queryable()
    |> preload([:matching_step_job, :transfer_step_job, :source_playlist])
    |> Transfer.filter_by(:user_id, user_id)
    |> Transfer.sort_by(:inserted_at, :desc)
    |> Repo.all()
  end
end
