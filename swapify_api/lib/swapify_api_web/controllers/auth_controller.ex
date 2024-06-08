defmodule SwapifyApiWeb.AuthController do
  use SwapifyApiWeb, :controller

  def signup(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    with {:ok, _} <- SwapifyApi.Accounts.Services.SignUpNewUser.call(data) do
      conn |> send_resp(204, "")
    end
  end

  def signin(conn, _) do
    # TODO
  end

  def signout(conn, _) do
    # TODO
  end
end
