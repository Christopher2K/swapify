defmodule SwapifyApiWeb.JobUpdateChannel do
  require Logger

  use SwapifyApiWeb, :channel

  alias SwapifyApi.Notifications.JobUpdateNotification
  alias SwapifyApi.Notifications.JobErrorNotification
  alias SwapifyApi.Utils

  @impl true
  def join("job_update:" <> _user_id, _payload, socket), do: {:ok, socket}

  # PUBLIC API

  @spec broadcast_job_progress(String.t(), JobUpdateNotification.t() | JobErrorNotification.t()) ::
          :ok
  def broadcast_job_progress(user_id, notification) do
    case SwapifyApiWeb.Endpoint.broadcast(
           "job_update:#{user_id}",
           "job_update",
           notification |> Utils.struct_to_json()
         ) do
      :ok ->
        Logger.info("Broadcasted job progress")

      {:error, reason} ->
        Logger.error("Failed to broadcast job progress", reason: reason)
    end
  end
end
