# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :swapify_api,
  ecto_repos: [SwapifyApi.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :swapify_api, SwapifyApi.Repo, migration_primary_key: [name: :id, type: :binary_id]

config :swapify_api,
  app_url: "https://swapify.live",
  cookie_domain: ".swapify.live",
  http_client_opts: []

# Configures the endpoint
config :swapify_api, SwapifyApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: SwapifyApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SwapifyApi.PubSub,
  live_view: [signing_salt: "7XYblx6r"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :swapify_api, SwapifyApi.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :status]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :swapify_api, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10],
  repo: SwapifyApi.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
