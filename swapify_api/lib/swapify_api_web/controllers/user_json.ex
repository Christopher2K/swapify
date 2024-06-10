defmodule SwapifyApiWeb.UserJSON do
  alias SwapifyApi.Accounts.User

  def me(%{user: user}), do: %{"data" => User.to_map(user)}
end
