defmodule SwapifyApi.Oauth do
  def generate_state() do
    :rand.bytes(24) |> Base.encode16()
  end
end

