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

  pipeline :admin do
    plug :accepts, ["html"]
    plug :put_format, "html"
    plug :fetch_session
    plug :put_root_layout, html: {SwapifyApiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_flash
  end

  pipeline :admin_protected do
    plug SwapifyApi.Plugs.Authenticated, roles: [:admin]
  end

  scope "/admin", SwapifyApiWeb do
    pipe_through :admin

    get "/signin", AdminAuthController, :sign_in
    post "/signin", AdminAuthController, :sign_in_form
    get "/signout", AdminAuthController, :sign_out
  end

  scope "/admin", SwapifyApiWeb do
    pipe_through [:admin, :admin_protected]
    get "/", AdminDashboardController, :index
  end

  scope "/api/auth", SwapifyApiWeb do
    pipe_through :api

    post "/signup", AuthController, :sign_up
    post "/signin", AuthController, :sign_in
    get "/signout", AuthController, :sign_out
    post "/password-reset", AuthController, :new_password_reset_request
    patch "/password-reset", AuthController, :confirm_password_reset_request
  end

  scope "/api/users", SwapifyApiWeb do
    pipe_through :api_protected
    get "/me", UserController, :me
  end

  scope "/api/meta", SwapifyApiWeb do
    pipe_through :api_protected
    get "/", MetaController, :index
  end

  scope "/api/integrations", SwapifyApiWeb do
    pipe_through :api_protected

    get "/", IntegrationController, :index
    get "/spotify/login", IntegrationController, :spotify_login
    get "/spotify/callback", IntegrationController, :spotify_callback
    get "/applemusic/login", IntegrationController, :apple_music_login
    post "/applemusic/callback", IntegrationController, :apple_music_callback
  end

  scope "/api/playlists", SwapifyApiWeb do
    pipe_through :api_protected

    get "/library", PlaylistController, :search_library

    post "/sync-platform/:platform_name", PlaylistController, :start_sync_platform_job
    post "/sync-library/:platform_name", PlaylistController, :start_sync_library_job
  end

  scope "/api/transfers", SwapifyApiWeb do
    pipe_through :api_protected

    get "/", TransferController, :index
    post "/", TransferController, :start_transfer

    get "/:transfer_id", TransferController, :get_transfer
    patch "/:transfer_id/confirm", TransferController, :confirm_transfer
    patch "/:transfer_id/cancel", TransferController, :cancel_transfer
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
