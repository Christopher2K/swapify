defmodule SwapifyApiWeb.MetaController do
  @moduledoc "Meta controller"
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts

  def index(conn, _) do
    user_id = conn.assigns[:user_id]

    with {:ok, socket_token} <- Accounts.generate_socket_token(user_id) do
      conn
      |> put_status(200)
      |> render(:index, socket_token: socket_token)
    end
  end
end
