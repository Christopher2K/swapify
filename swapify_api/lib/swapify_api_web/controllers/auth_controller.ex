defmodule SwapifyApiWeb.AuthController do
  use SwapifyApiWeb, :controller

  @app_url Application.compile_env!(:swapify_api, :app_url)

  def signup(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    with {:ok, _} <- SwapifyApi.Accounts.Services.SignUpNewUser.call(data) do
      conn |> send_resp(204, "")
    end
  end

  def signin(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    case SwapifyApi.Accounts.Services.SignInUser.call(data["email"], data["password"]) do
      {:ok, user} ->
        conn
        |> SwapifyApi.Accounts.UserSession.create_user_session(user)
        |> redirect(external: "#{@app_url}/app/dashboard")

      {:error, _} ->
        conn
        |> redirect(external: "#{@app_url}/login/error")
    end
  end

  def signout(conn, _) do
    conn
    |> SwapifyApi.Accounts.UserSession.delete_user_session()
    |> redirect(external: "#{@app_url}")
  end
end
