defmodule SwapifyApiWeb.Router do
  use SwapifyApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :api_protected do
    plug :accepts, ["json"]
    plug :fetch_session
    plug SwapifyApi.Plugs.Authenticated
  end

  scope "/api/auth", SwapifyApiWeb do
    pipe_through :api
    post "/signup", AuthController, :sign_up
    post "/signin", AuthController, :sign_in
  end

  scope "/api/users", SwapifyApiWeb do
    pipe_through :api_protected
    get "/me", UserController, :me
  end

  scope "/api/integrations", SwapifyApiWeb do
    pipe_through :api_protected

    get "/spotify/login", IntegrationController, :spotify_login
    get "/spotify/callback", IntegrationController, :spotify_callback
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:swapify_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: SwapifyApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
