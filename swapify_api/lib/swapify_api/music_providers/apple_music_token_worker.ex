defmodule SwapifyApi.MusicProviders.AppleMusicTokenWorker do
  use GenServer

  alias SwapifyApi.MusicProviders.AppleMusicDeveloperToken

  @token_validity 5400
  @renew_interval 1800

  # Client Api
  def start_link(args) do
    GenServer.start_link(__MODULE__, [], name: args[:name])
  end

  def get() do
    GenServer.call(SwapifyApi.AppleMusicWorker, :get)
  end

  # Server API
  @impl true
  def init(_), do: refresh_token()

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, Keyword.get(state, :token), state}
  end

  @impl true
  def handle_info(:refresh, _state) do
    {:ok, state} = refresh_token()
    {:noreply, state}
  end

  # Helpers

  defp refresh_token() do
    token = AppleMusicDeveloperToken.create!(token_validity: @token_validity)
    timer_ref = Process.send_after(self(), :refresh, :timer.seconds(@renew_interval))
    {:ok, token: token, timer_ref: timer_ref}
  end
end
