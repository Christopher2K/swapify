defmodule SwapifyApi.Repo do
  use Ecto.Repo,
    otp_app: :swapify_api,
    adapter: Ecto.Adapters.Postgres
end
