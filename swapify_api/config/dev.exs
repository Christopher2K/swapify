import Config

config :swapify_api,
  dev_routes: true

config :swapify_api, SwapifyApi.Repo,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :swapify_api, SwapifyApiWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "x/uCwvbg8iAhcJCVkilmNcaDISKWciCOHQlUxhxMjkeJVSjEBZ9mf5iEi54lb6cw",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :swoosh, :api_client, false

if System.get_env("DEBUG_OTEL") == "true" do
  # Print traces to stdout
  # config :opentelemetry, :processors,
  #   otel_batch_processor: %{
  #     exporter: {:otel_exporter_stdout, []}
  #   }

  # Send traces to OTLP exporter on localhost
  config :opentelemetry,
    resource: [service: %{name: "swapify_platform", version: "0.1.0"}],
    span_processor: :batch,
    exporter: :otlp

  config :opentelemetry_exporter,
    otlp_protocol: :http_protobuf,
    otlp_endpoint: "http://localhost:4318"
else
  config :opentelemetry, traces_exporter: :none
end
