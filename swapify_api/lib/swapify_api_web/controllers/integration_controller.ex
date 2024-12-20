defmodule SwapifyApiWeb.IntegrationController do
  use SwapifyApiWeb, :controller

  require Logger
  alias SwapifyApi.Utils
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.MusicProviders.AppleMusicDeveloperToken
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.Oauth
  alias SwapifyApi.Accounts

  def index(%Plug.Conn{} = conn, _) do
    user_id = conn.assigns[:user_id]
    platform_connections = PlatformConnectionRepo.get_by_user_id(user_id)

    conn
    |> put_status(200)
    |> render(:index, platform_connections: platform_connections)
  end

  def spotify_login(%Plug.Conn{} = conn, _) do
    state = Oauth.generate_state()
    redirect_url = Spotify.generate_auth_url(state)

    conn
    |> put_session(:spotify_state, state)
    |> put_status(301)
    |> redirect(external: redirect_url)
  end

  def spotify_callback(%Plug.Conn{} = conn, %{"code" => code, "state" => remote_state}) do
    user_id = conn.assigns[:user_id]
    session_state = get_session(conn, :spotify_state)

    result =
      Accounts.create_or_update_integration(:spotify,
        remote_state: remote_state,
        session_state: session_state,
        code: code,
        user_id: user_id
      )

    case result do
      {:ok, _} ->
        conn
        |> delete_session(:spotify_state)
        |> redirect(external: Utils.get_app_url("/integrations/spotify?result=success"))

      {:error, %{message: error_message}} ->
        conn
        |> delete_session(:spotify_state)
        |> redirect(
          external:
            Utils.get_app_url(
              "/integrations/spotify?result=error&error=#{URI.encode(error_message)}"
            )
        )

      _ ->
        conn
        |> delete_session(:spotify_state)
        |> redirect(
          external:
            Utils.get_app_url(
              "/integrations/spotify?result=error&error=#{URI.encode("Unexpected error, please try again.")}"
            )
        )
    end
  end

  def spotify_callback(%Plug.Conn{} = conn, _) do
    conn
    |> delete_session(:spotify_state)
    |> redirect(
      external:
        Utils.get_app_url(
          "/integrations/spotify?result=error&error=#{URI.encode("Unexpected error, please try again.")}"
        )
    )
  end

  def apple_music_login(%Plug.Conn{} = conn, _) do
    developer_token = AppleMusicDeveloperToken.create!(token_validity: 120)

    conn
    |> put_status(200)
    |> render(:apple_music_login, token: developer_token)
  end

  def apple_music_callback(%Plug.Conn{body_params: %{"authToken" => apple_user_token}} = conn, _) do
    user_id = conn.assigns[:user_id]

    with {:ok, _} <-
           Accounts.create_or_update_integration(:applemusic,
             user_id: user_id,
             token: apple_user_token
           ) do
      {:ok}
    end
  end
end
