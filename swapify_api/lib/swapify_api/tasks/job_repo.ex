defmodule SwapifyApi.Tasks.JobRepo do
  alias SwapifyApi.Utils
  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.Repo

  def create(args),
    do:
      %Job{}
      |> Job.changeset(args)
      |> Repo.insert(returning: true)

  @spec update(String.t(), map()) ::
          {:ok, Job.t()} | {:error, ErrorMessage.t() | Ecto.Changeset.t()}
  def update(id, args) do
    with({:ok, job} <- get_by_id(id)) do
      job
      |> Job.changeset(args)
      |> Repo.update(returning: true)
    end
  end

  @spec get_by_id(String.t()) :: {:ok, Job.t()} | {:error, ErrorMessage.t()}
  def get_by_id(id),
    do:
      Job.queryable()
      |> Job.filter_by(:id, id)
      |> Repo.one()
      |> Utils.from_nullable_to_tuple()
end
