defmodule SwapifyApiWeb.UserController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts.UserRepo

  def me(%Plug.Conn{} = conn, _) do
    user_id = conn.assigns[:user_id]

    with {:ok, user} <- UserRepo.get_by(:id, user_id) do
      conn |> render(:me, user: user)
    else
      _ ->
        {:error, :unauthorized}
    end
  end
end
