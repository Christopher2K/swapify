defmodule SwapifyApi.Accounts.Services.GenerateAuthTokens do
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.Accounts.Token

  @access_token_validity 3600
  @refresh_token_validity 86400

  @spec call(String.t()) ::
          {:ok, User.t(), Joken.bearer_token(), Joken.bearer_token()} | {:error, :unauthorized}
  def call(user) do
    with claims <- get_jwt_claims(user),
         {:ok, access_token, _} <- Token.generate_and_sign(claims["access"]),
         {:ok, refresh_token, _} <- Token.generate_and_sign(claims["refresh"]) do
      {:ok, user, access_token, refresh_token}
    else
      {:error, _} -> {:error, :server_error}
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
