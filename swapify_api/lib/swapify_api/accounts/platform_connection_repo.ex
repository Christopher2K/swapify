defmodule SwapifyApi.Accounts.PlatformConnectionRepo do
  @moduledoc "PlatformConnection Repository"
  alias SwapifyApi.Repo
  alias SwapifyApi.Accounts.PlatformConnection

  @spec create_or_update(String.t(), String.t(), map()) ::
          {:ok, PlatformConnection.t()} | {:error, Ecto.Changeset.t()}
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

      pc ->
        pc
        |> PlatformConnection.update_changeset(update_changes)
        |> Repo.update()
    end
  end

  @spec delete(String.t(), String.t()) :: {:ok}
  def delete(user_id, name) do
    PlatformConnection.queryable()
    |> PlatformConnection.filter_by(:user_id, user_id)
    |> PlatformConnection.filter_by(:name, name)
    |> Repo.delete_all()

    {:ok}
  end
end
