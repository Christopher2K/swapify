defmodule SwapifyApiWeb.UserSocket do
  use Phoenix.Socket

  alias SwapifyApi.Accounts

  channel "job_update:*", SwapifyApiWeb.JobUpdateChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Accounts.validate_socket_token(token) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}

      {:error, _} ->
        :error
    end
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
