defmodule SwapifyApi.Accounts.Services.SignUpNewUser do
  @moduledoc "Create a new user with all the side effect associated with this event"

  alias SwapifyApi.Accounts.UserRepo
  alias SwapifyApi.Accounts.User

  @doc """
  Expects a map with those properties
  - email
  - password
  """
  @spec call(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def call(registration_data) do
    # TODO: Email on registration
    UserRepo.create(registration_data)
  end
end
