defmodule SwapifyApiWeb.AdminDashboardController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Operations
  alias SwapifyApi.Accounts

  plug :put_layout, {SwapifyApiWeb.Layouts, :admin}

  def index(conn, _) do
    with {:ok, user_count} <- Accounts.count_users(),
         {:ok, transfer_count} <- Operations.count_transfers() do
      conn |> render(:index, user_count: user_count, transfer_count: transfer_count)
    end
  end
end
