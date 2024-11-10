import Config

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: SwapifyApi.Finch

config :swoosh, local: false

nr_app_name = System.get_env("NR_APP_NAME")
nr_license_key = System.get_env("NR_LICENSE_KEY")

config :new_relic_agent,
  app_name: nr_app_name,
  license_key: nr_license_key

config :logger,
  level: :info,
  handle_sasl_reports: true,
  backends: [:console, NewRelic.ErrorLogger]
