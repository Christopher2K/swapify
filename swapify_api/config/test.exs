import Config

config :swapify_api,
  http_client_opts: [
    plug: {Req.Test, :test}
  ]

config :swapify_api, SwapifyApi.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :swapify_api, SwapifyApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "hd8wQ+fnNC2MzTSn/pSXrHSJBNywnVhXNIq1Zd6MXq8s5ut1OcUWlre0VzAs+JXw",
  server: false

config :swapify_api, Oban, testing: :manual

config :swapify_api, SwapifyApi.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :opentelemetry, traces_exporter: :none

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
