defmodule SwapifyApiWeb.TransferController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Operations

  def index(%Plug.Conn{} = conn, _) do
    user_id = conn.assigns[:user_id]

    with {:ok, transfers} <- Operations.list_transfers_by_user_id(user_id) do
      conn
      |> put_status(200)
      |> render(:index, transfers: transfers)
    end
  end

  def start_transfer(%Plug.Conn{} = conn, %{
        "playlist" => playlist_id,
        "destination" => destination
      }) do
    user_id = conn.assigns[:user_id]

    with {:ok, transfer} <-
           Operations.start_playlist_transfer_matching_step(user_id, playlist_id, destination) do
      conn
      |> put_status(200)
      |> render(:show, transfer: transfer)
    end
  end

  def get_transfer(%Plug.Conn{} = _conn, _) do
    # TODO
  end

  def confirm_transfer(%Plug.Conn{} = conn, %{
        "transfer_id" => transfer_id
      }) do
    user_id = conn.assigns[:user_id]

    with {:ok, %{transfer: transfer}} <-
           Operations.start_playlist_transfer_transfer_step(user_id, transfer_id) do
      conn
      |> put_status(200)
      |> render(:show, transfer: transfer)
    end
  end

  def cancel_transfer(%Plug.Conn{} = conn, %{
        "transfer_id" => transfer_id
      }) do
    user_id = conn.assigns[:user_id]

    with {:ok, transfer} <- Operations.cancel_transfer(user_id, transfer_id) do
      conn
      |> put_status(200)
      |> render(:show, transfer: transfer)
    end
  end
end
