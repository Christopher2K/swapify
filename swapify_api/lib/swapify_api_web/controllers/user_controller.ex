defmodule SwapifyApiWeb.UserController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts.UserRepo

  def me(%Plug.Conn{} = conn, _) do
    user_id = conn.assigns[:user_id]
    {:ok, user} = UserRepo.get_by(:id, user_id)
    conn |> render(:me, user: user)
  end
end

