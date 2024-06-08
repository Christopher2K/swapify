defmodule SwapifyApi.Accounts.UserRepo do
  @moduledoc "User model repository"
  alias SwapifyApi.Repo
  alias SwapifyApi.Accounts.User

  @spec create(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create(data) do
    %User{}
    |> User.create_changeset(data)
    |> Repo.insert()
  end
end
