import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

if System.get_env("PHX_SERVER") do
  config :swapify_api, SwapifyApiWeb.Endpoint, server: true
end

config :swapify_api, SwapifyApi.MusicProviders.Spotify,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  client_secret: System.get_env("SPOTIFY_CLIENT_SECRET")

config :swapify_api, SwapifyApi.MusicProviders.AppleMusic,
  team_id: System.get_env("APPLE_MUSIC_TEAM_ID"),
  key_id: System.get_env("APPLE_MUSIC_KID"),
  private_key: System.get_env("APPLE_MUSIC_PRIVATE_KEY")

config :joken, default_signer: System.get_env("JWT_SECRET")

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :swapify_api, SwapifyApi.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PLATFORM_HOST")
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :swapify_api, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :swapify_api, SwapifyApiWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  config :swapify_api, SwapifyApi.Mailer,
    adapter: Swoosh.Adapters.ZeptoMail,
    base_url: System.get_env("ZEPTO_BASE_URL"),
    api_key: SYSTEM.get_env("ZEPTO_API_KEY")
else
  database_url = System.get_env("DATABASE_URL")
  config :swapify_api, SwapifyApi.Repo, url: database_url
end
