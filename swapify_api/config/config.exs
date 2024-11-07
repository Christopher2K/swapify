import Config

app_url = System.get_env("APP_URL")
api_url = System.get_env("API_URL")
platform_host = System.get_env("PLATFORM_HOST") || "localhost"

config :swapify_api,
  ecto_repos: [SwapifyApi.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true],
  http_client_opts: [],
  app_url: app_url,
  api_url: api_url,
  cookie_domain:
    if(platform_host == "localhost",
      do: "localhost",
      else: "." <> platform_host
    )

config :swapify_api, SwapifyApi.Repo, migration_primary_key: [name: :id, type: :binary_id]

config :swapify_api, SwapifyApiWeb.Endpoint,
  url: [host: platform_host],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: SwapifyApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SwapifyApi.PubSub,
  live_view: [signing_salt: "7XYblx6r"]

config :swapify_api, Oban,
  engine: Oban.Engines.Basic,
  queues: [sync_library: 50, sync_platform: 50, search_tracks: 100, transfer_tracks: 50],
  repo: SwapifyApi.Repo

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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
