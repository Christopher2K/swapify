import Config

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: SwapifyApi.Finch

config :swoosh, local: false

config :logger,
  level: :info,
  backends: [:console],
  default_handler: [formatter: {LoggerJSON.Formatters.Basic, metadata: :all}]
