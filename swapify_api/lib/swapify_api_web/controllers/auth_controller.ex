defmodule SwapifyApiWeb.AuthController do
  use SwapifyApiWeb, :controller

  @app_url Application.compile_env!(:swapify_api, :app_url)

  def sign_up(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    with {:ok, _} <- SwapifyApi.Accounts.Services.SignUpNewUser.call(data) do
      conn |> send_resp(204, "")
    end
  end

  def sign_in(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    case SwapifyApi.Accounts.Services.SignInUser.call(data["email"], data["password"]) do
      {:ok, user, access_token, refresh_token} ->
        conn
        |> put_status(200)
        |> render(:signin, access_token: access_token, refresh_token: refresh_token, user: user)

      error ->
        error
    end
  end

  def sign_out(conn, _) do
    conn
    |> SwapifyApi.Accounts.UserSession.delete_user_session()
    |> redirect(external: "#{@app_url}")
  end
end
