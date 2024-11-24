defmodule SwapifyApiWeb.AdminDashboardController do
  use SwapifyApiWeb, :controller

  plug :put_layout, {SwapifyApiWeb.Layouts, :admin}

  def index(conn, _), do: conn |> render(:index)
end
