defmodule SwapifyApiWeb.IntegrationController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.MusicProviders.Spotify

  def spotify_login(%Plug.Conn{} = conn, _) do
    state = SwapifyApi.Oauth.generate_state()
    redirect_url = Spotify.generate_auth_url(state) |> dbg

    conn
    |> put_session(:spotify_state, state)
    |> put_status(301)
    |> redirect(external: redirect_url)
  end

  def spotify_callback(%Plug.Conn{} = conn, _) do
    # state = conn |> get_session(:spotify_state)

    conn
    |> delete_session(:spotify_state)
    |> redirect(external: "http://localhost:3000/app/integration?loading=spotify")
  end
end
