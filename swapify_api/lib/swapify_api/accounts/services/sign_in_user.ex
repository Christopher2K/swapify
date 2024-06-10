defmodule SwapifyApi.Accounts.Services.SignInUser do
  @moduledoc """
  Signs in an user
  """
  alias SwapifyApi.Accounts.User

  @spec call(String.t(), String.t()) ::
          {:ok, User.t(), Joken.bearer_token(), Joken.bearer_token()} | {:error, :unauthorized}
  def call(email, password) do
    with {:ok, user} <-
           SwapifyApi.Accounts.Services.ValidateUserCredentials.call(email, password),
         {:ok, _, _, _} = user_auth_data <-
           SwapifyApi.Accounts.Services.GenerateAuthTokens.call(user) do
      user_auth_data
    else
      _ -> {:error, :unauthorized}
    end
  end
end
