defmodule SwapifyApiWeb.IntegrationController do
  use SwapifyApiWeb, :controller

  require Logger
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Oauth
  alias SwapifyApi.Accounts

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
      Accounts.Services.CreateOrUpdateIntegration.call("spotify",
        remote_state: remote_state,
        session_state: session_state,
        code: code,
        user_id: user_id
      )

    case result do
      {:ok, _} ->
        conn
        |> delete_session(:spotify_state)
        |> redirect(external: "http://localhost:3000/app/integration?service=spotify")

      {:error, error} ->
        conn
        |> delete_session(:spotify_state)
        |> redirect(
          external:
            "http://localhost:3000/app/integration?service=spotify&error=#{Atom.to_string(error)}"
        )
    end
  end

  def spotify_callback(%Plug.Conn{} = conn, _) do
    conn
    |> delete_session(:spotify_state)
    |> redirect(
      external: "http://localhost:3000/app/integration?service=spotify&error=service_error"
    )
  end
end
