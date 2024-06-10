defmodule SwapifyApi.Accounts.Services.ValidateUserCredentials do
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.Accounts.UserRepo

  @spec call(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, :unauthorized} | {:error, :not_found}
  def call(email, password) do
    with {:ok, user} <- UserRepo.get_by(:email, email) do
      check_password(user, password)
    end
  end

  @spec check_password(User.t(), String.t()) :: {:ok, User.t()} | {:error, :unauthorized}
  defp check_password(%User{} = user, password_input) do
    is_valid? =
      SwapifyApi.Accounts.Services.UserPasswordHashing.verify(password_input, user.password)

    if is_valid? do
      {:ok, user}
    else
      {:error, :unauthorized}
    end
  end
end
