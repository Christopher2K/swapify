defmodule SwapifyApi.Accounts.Services.SignInUser do
  @moduledoc """
  Signs in an user:
  - Get user
  - Check password validity
  """
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.Accounts.UserRepo
  alias SwapifyApi.Accounts.Token

  @access_token_validity 3600
  @refresh_token_validity 86400

  @spec call(String.t(), String.t()) ::
          {:ok, User.t(), Joken.bearer_token(), Joken.bearer_token()} | {:error, :unauthorized}
  def call(email, password) do
    with {:ok, user} <- UserRepo.get_by(:email, email),
         {:ok, user} <- check_password(user, password),
         claims <- get_jwt_claims(user),
         {:ok, access_token, _} <- Token.generate_and_sign(claims["access"]),
         {:ok, refresh_token, _} <- Token.generate_and_sign(claims["refresh"]) do
      {:ok, user, access_token, refresh_token}
    else
      _ -> {:error, :unauthorized}
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

  defp get_jwt_claims(%User{} = user) do
    now = DateTime.utc_now() |> DateTime.to_unix()

    %{
      "access" => %{
        "iat" => now,
        "exp" => now + @access_token_validity,
        "user_id" => user.id,
        "user_email" => user.email
      },
      "refresh" => %{
        "iat" => now,
        "exp" => now + @refresh_token_validity,
        "user_id" => user.id,
        "user_email" => user.email
      }
    }
  end
end
