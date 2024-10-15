defmodule SwapifyApiWeb.TransferController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Tasks

  def index(%Plug.Conn{} = _conn, _) do
    # TODO
  end

  def start_transfer(%Plug.Conn{} = conn, %{"playlist" => playlist_id, "transfer" => transfer_id}) do
    user_id = conn.assigns[:user_id]

    with {:ok, transfer} <-
           Tasks.start_playlist_transfer_matching_step(user_id, playlist_id, transfer_id) do
      conn
      |> put_status(200)
      |> render(:show, transfer: transfer)
    end
  end

  def get_transfer(%Plug.Conn{} = _conn, _) do
    # TODO
  end

  def confirm_transfer(%Plug.Conn{} = _conn, _) do
    # TODO
  end

  def cancel_transfer(%Plug.Conn{} = _conn, _) do
    # TODO
  end
end
