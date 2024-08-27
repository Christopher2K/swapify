defmodule SwapifyApi.Accounts.Services.ValidateSocketToken do
  @moduledoc "Validate a socket token for a given user"

  alias Phoenix.Token

  @max_age 60 * 60
  @namespace "user_socket"

  @spec call(String.t()) :: {:ok, String.t()} | {:error, :unauthorized}
  def call(token) do
    secret =
      Keyword.get(Application.get_env(:swapify_api, SwapifyApiWeb.Endpoint), :secret_key_base)

    with {:ok, _} = result <-
           Token.verify(secret, @namespace, token, max_age: @max_age) do
      result
    else
      _ -> {:error, :unauthorized}
    end
  end
end
