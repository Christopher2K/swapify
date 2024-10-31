defmodule SwapifyApi.Oauth do
  def generate_state() do
    :rand.bytes(24) |> Base.encode16()
  end

  @spec check_state(String.t(), String.t()) :: {:ok} | {:error, ErrorMessage.t()}
  def check_state(base_state, remote_state) do
    if base_state == remote_state <> "_" do
      {:ok}
    else
      {:error, ErrorMessage.bad_request("State mismatch")}
    end
  end
end
