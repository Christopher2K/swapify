defmodule SwapifyApiWeb.UserJSON do
  alias SwapifyApi.Accounts

  def me(%{user: user}), do: %{"data" => Accounts.UserJSON.show(user)}
end
