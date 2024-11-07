defmodule SwapifyApiWeb.AuthJSON do
  alias SwapifyApi.Accounts.UserJSON

  def sign_up(%{user: user}), do: %{"data" => UserJSON.show(user)}

  def sign_in(%{user: user}), do: %{"data" => UserJSON.show(user)}
end
