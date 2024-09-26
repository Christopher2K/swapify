defmodule SwapifyApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :swapify_api

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_swapify_api_key",
    signing_salt: "zNobAVSf",
    same_site: "Lax",
    domain: Application.compile_env!(:swapify_api, :cookie_domain)
  ]

  @allowed_origins [
    Application.compile_env!(:swapify_api, :app_url)
  ]

  @allowed_headers [
    "Baggage",
    "Sentry-Trace",
    "x-swapify-application" | CORSPlug.defaults()[:headers]
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  socket "/user_socket", SwapifyApiWeb.UserSocket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :swapify_api,
    gzip: false,
    only: SwapifyApiWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :swapify_api
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug CORSPlug,
    origin: @allowed_origins,
    headers: @allowed_headers

  plug SwapifyApiWeb.Router
end
