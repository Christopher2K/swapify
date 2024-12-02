defmodule SwapifyApiWeb.TransferJSON do
  alias SwapifyApi.Operations

  def index(%{transfers: transfers}), do: %{"data" => Operations.TransferJSON.list(transfers)}

  def show(%{transfer: transfer}), do: %{"data" => Operations.TransferJSON.show(transfer)}
end
