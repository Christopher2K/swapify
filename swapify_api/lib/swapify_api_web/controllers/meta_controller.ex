defmodule SwapifyApiWeb.MetaController do
  @moduledoc "Meta controller"
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts.Services.GenerateSocketToken

  def index(conn, _) do
    user_id = conn.assigns[:user_id]

    with {:ok, socket_token} <- GenerateSocketToken.call(user_id) do
      conn
      |> put_status(200)
      |> render(:index, socket_token: socket_token)
    end
  end
end
