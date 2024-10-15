defmodule SwapifyApiWeb.TransferJSON do
  alias SwapifyApi.Tasks

  def index(%{transfers: transfers}), do: %{"data" => Tasks.TransferJSON.list(transfers)}

  def show(%{transfer: transfer}), do: %{"data" => Tasks.TransferJSON.show(transfer)}
end
