defmodule SwapifyApiWeb.Router do
  use SwapifyApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :api_protected do
    plug SwapifyApi.Plugs.Authenticated
  end

  pipeline :admin do
    plug :accepts, ["html"]
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
    get "/users", AdminUserController, :index
    get "/users/:id", AdminUserController, :show
    post "/users/:id/update-role", AdminUserController, :update_role
  end

  scope "/api/auth", SwapifyApiWeb do
    pipe_through :api

    post "/signup", AuthController, :sign_up
    post "/signin", AuthController, :sign_in
    get "/signout", AuthController, :sign_out
    post "/password-reset", AuthController, :new_password_reset_request
    patch "/password-reset", AuthController, :confirm_password_reset_request
  end

  scope "/api", SwapifyApiWeb do
    pipe_through [:api, :api_protected]

    get "/meta", MetaController, :index
    get "/users/me", UserController, :me

    get "/integrations", IntegrationController, :index
    get "/integrations/spotify/login", IntegrationController, :spotify_login
    get "/integrations/spotify/callback", IntegrationController, :spotify_callback
    get "/integrations/applemusic/login", IntegrationController, :apple_music_login
    post "/integrations/applemusic/callback", IntegrationController, :apple_music_callback

    get "/playlists/library", PlaylistController, :search_library
    post "/playlists/sync-platform/:platform_name", PlaylistController, :start_sync_platform_job
    post "/playlists/sync-library/:platform_name", PlaylistController, :start_sync_library_job

    get "/transfers/", TransferController, :index
    post "/transfers/", TransferController, :start_transfer

    get "/transfers/:transfer_id", TransferController, :get_transfer
    patch "/transfers/:transfer_id/confirm", TransferController, :confirm_transfer
    patch "/transfers/:transfer_id/cancel", TransferController, :cancel_transfer
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
