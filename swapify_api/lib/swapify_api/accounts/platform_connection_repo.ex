defmodule SwapifyApi.Accounts.PlatformConnectionRepo do
  @moduledoc "PlatformConnection Repository"

  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Repo
  alias SwapifyApi.Utils

  @doc """
  Create if it doesn'texist or update a platform connection data for a given user
  """
  @spec create_or_update(String.t(), String.t(), map()) ::
          {:ok, PlatformConnection.t(), :created | :updated} | {:error, Ecto.Changeset.t()}
  def create_or_update(user_id, name, update_changes) do
    mb_pc =
      PlatformConnection.queryable()
      |> PlatformConnection.filter_by(:user_id, user_id)
      |> PlatformConnection.filter_by(:name, name)
      |> Repo.one()

    case mb_pc do
      nil ->
        %PlatformConnection{}
        |> PlatformConnection.changeset(
          update_changes
          |> Map.merge(%{
            "user_id" => user_id,
            "name" => name
          })
        )
        |> Repo.insert()
        |> case do
          {:ok, pc} ->
            {:ok, pc, :created}

          error ->
            error
        end

      pc ->
        pc
        |> PlatformConnection.update_changeset(update_changes)
        |> Repo.update()
        |> case do
          {:ok, pc} ->
            {:ok, pc, :updated}

          error ->
            error
        end
    end
  end

  @spec delete(String.t(), PlatformConnection.platform_name()) :: {:ok}
  def delete(user_id, name) do
    PlatformConnection.queryable()
    |> PlatformConnection.filter_by(:user_id, user_id)
    |> PlatformConnection.filter_by(:name, name)
    |> Repo.delete_all()

    {:ok}
  end

  @spec get_by_user_id(String.t()) :: list(PlatformConnection.t())
  def get_by_user_id(user_id) do
    PlatformConnection.queryable()
    |> PlatformConnection.filter_by(:user_id, user_id)
    |> Repo.all()
  end

  @spec get_by_user_id_and_platform(String.t(), String.t()) ::
          {:ok, PlatformConnection.t()} | {:error, :not_found}
  def get_by_user_id_and_platform(user_id, platform_name) do
    PlatformConnection.queryable()
    |> PlatformConnection.filter_by(:user_id, user_id)
    |> PlatformConnection.filter_by(:name, platform_name)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end
end
