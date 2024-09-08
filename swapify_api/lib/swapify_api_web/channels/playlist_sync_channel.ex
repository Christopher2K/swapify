defmodule SwapifyApiWeb.PlaylistSyncChannel do
  require Logger

  use SwapifyApiWeb, :channel

  alias SwapifyApi.MusicProviders.SyncNotification

  @impl true
  def join("playlist_sync", _payload, socket), do: {:ok, socket}

  # PUBLIC API

  def broadcast_sync_progress(user_id, %SyncNotification{} = notification) do
    case SwapifyApiWeb.Endpoint.broadcast(
           "user_socket:#{user_id}",
           "status_update",
           notification |> SyncNotification.to_json()
         ) do
      :ok ->
        Logger.info("Broadcasted sync progress")

      {:error, reason} ->
        Logger.error("Failed to broadcast sync progress", reason: reason)
    end

    :ok
  end
end
