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
  repo: SwapifyApi.Repo,
  engine: Oban.Engines.Basic,
  queues: [sync_library: 50, sync_platform: 50, search_tracks: 100, transfer_tracks: 50],
  plugins: [
    {Oban.Plugins.Pruner, max_age: 86_400},
    Oban.Plugins.Reindexer,
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(2)}
  ]

config :swapify_api, SwapifyApi.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id, :otel_trace_id, :otel_span_id]

config :phoenix, :json_library, Jason

config :o11y, :attribute_namespace, "swapify.app"

config :hammer,
  # Expiry: 4 hours
  # Cleanup: Every 10 minutes
  backend: {Hammer.Backend.Mnesia, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

config :esbuild,
  version: "0.23.0",
  default: [
    args: ~w(js/app.ts --bundle --target=es2017 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=js/tailwind.config.js
      --input=js/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
