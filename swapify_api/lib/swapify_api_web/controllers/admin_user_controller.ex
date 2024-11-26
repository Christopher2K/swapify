defmodule SwapifyApiWeb.AdminUserController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts

  plug :put_layout, {SwapifyApiWeb.Layouts, :admin}

  def index(conn, params) do
    limit = 20
    page = Map.get(params, "page", 1)
    offset = limit * (page - 1)

    with {:ok, %{users: users, count: count}} <- Accounts.list_users(offset, limit) do
      conn |> render(:index, users: users, count: count)
    end
  end
end
