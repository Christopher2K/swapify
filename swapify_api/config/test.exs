import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :swapify_api, SwapifyApi.Repo,
  username: "admin",
  password: "swapifypassword",
  hostname: "localhost",
  database: "swapify_test",
  port: 54321,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :swapify_api, SwapifyApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "hd8wQ+fnNC2MzTSn/pSXrHSJBNywnVhXNIq1Zd6MXq8s5ut1OcUWlre0VzAs+JXw",
  server: false

# In test we don't send emails.
config :swapify_api, SwapifyApi.Mailer, adapter: Swoosh.Adapters.Test

config :swapify_api, Oban, testing: :inline

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Speed up Argon2 during tests
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :swapify_api,
  http_client_opts: [
    plug: {Req.Test, :test}
  ]
