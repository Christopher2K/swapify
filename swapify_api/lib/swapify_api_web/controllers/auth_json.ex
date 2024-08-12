defmodule SwapifyApiWeb.AuthJSON do
  alias SwapifyApi.Accounts.User

  def sign_up(%{user: user}), do: %{"data" => User.to_map(user)}

  def sign_in(%{user: user}), do: %{"data" => User.to_map(user)}
end
