defmodule SwapifyApi.Oauth do
  def generate_state() do
    :rand.bytes(24) |> Base.encode16()
  end

  @spec check_state(String.t(), String.t()) :: {:ok} | SwapifyApi.Errors.t()
  def check_state(base_state, remote_state) do
    if base_state == remote_state do
      {:ok}
    else
      SwapifyApi.Errors.state_mismatch()
    end
  end
end
