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

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Accounts.get_by_id(id) do
      conn |> render(:show, user: user)
    end
  end

  def update_role(conn, %{"id" => id, "new_role" => new_role}) do
    with {:ok, user} <- Accounts.get_by_id(id),
         {:ok, user} <- Accounts.update_role(user, new_role) do
      conn
      |> put_flash(:success, "Role updated successfully")
      |> redirect(to: ~p"/admin/users/#{user.id}")
    else
      error ->
        error |> dbg
    end
  end
end
