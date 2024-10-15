defmodule SwapifyApiWeb.TransferJSON do
  alias SwapifyApi.Tasks

  def show(%{transfer: transfer}), do: %{"data" => Tasks.TransferJSON.show(transfer)}
end
