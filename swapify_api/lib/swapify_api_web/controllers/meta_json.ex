defmodule SwapifyApiWeb.MetaJSON do
  @moduledoc "Meta JSON"

  def index(%{socket_token: socket_token}), do: %{"data" => %{"socketToken" => socket_token}}
end
