defmodule SwapifyApi.Accounts.PasswordResetRequestRepo do
  import Ecto.Query, warn: false

  alias SwapifyApi.Repo
  alias SwapifyApi.Utils
  alias SwapifyApi.Accounts.PasswordResetRequest
  alias SwapifyApi.Accounts.User

  @doc """
  Get a password reset request by code, always includes the user
  """
  @spec get_by_code(String.t()) :: {:ok, PasswordResetRequest.t()} | {:error, ErrorMessage.t()}
  def get_by_code(code) do
    from(pr in PasswordResetRequest,
      left_join: u in User,
      on: pr.user_id == u.id,
      where: pr.code == ^code,
      preload: [user: u]
    )
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  @doc """
  Create a new password reset request
  """
  @spec create(String.t()) :: {:ok, PasswordResetRequest.t()} | {:error, Ecto.Changeset.t()}
  def create(user_id) do
    %PasswordResetRequest{}
    |> PasswordResetRequest.create_changeset(%{
      "user_id" => user_id
    })
    |> Repo.insert(returning: true)
  end

  @doc """
  Mark a password reset request as used
  """
  @spec mark_as_used(String.t()) :: {:ok, PasswordResetRequest.t()} | {:error, ErrorMessage.t()}
  def mark_as_used(code) do
    from(pr in PasswordResetRequest,
      where: pr.code == ^code,
      update: [
        set: [
          is_used: true
        ]
      ]
    )
    |> Repo.update_all([])
  end
end
