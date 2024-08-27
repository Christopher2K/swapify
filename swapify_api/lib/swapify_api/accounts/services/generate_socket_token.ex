defmodule SwapifyApi.Accounts.Services.GenerateSocketToken do
  @moduledoc "Generate a socket token for a given user"

  alias SwapifyApi.Utils
  alias Phoenix.Token

  @namespace "user_socket"

  @spec call(String.t()) :: {:ok, String.t()}
  def call(user_id) do
    secret =
      Keyword.get(Application.get_env(:swapify_api, SwapifyApiWeb.Endpoint), :secret_key_base)

    Token.sign(
      secret,
      @namespace,
      user_id
    )
    |> Utils.from_nullable_to_tuple()
  end
end
