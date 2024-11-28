defmodule SwapifyApiWeb.AuthController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts
  alias SwapifyApi.Utils

  # Shared rate limit
  # rate_limit(
  #   "auth",
  #   [:sign_up, :new_password_reset_request, :confirm_password_reset_request],
  #   :timer.minutes(30),
  #   100
  # )

  def sign_up(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    with {:ok, user} <- Accounts.sign_up_new_user(data) do
      conn
      |> put_status(200)
      |> render(:sign_up, user: user)
    end
  end

  def sign_in(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    case Accounts.sign_in_user(data["email"], data["password"]) do
      {:ok, user, access_token, refresh_token} ->
        conn
        |> put_session(:access_token, access_token)
        |> put_session(:refresh_token, refresh_token)
        |> put_status(200)
        |> render(:sign_in, user: user)

      error ->
        error
    end
  end

  def sign_out(%Plug.Conn{} = conn, _) do
    conn
    |> delete_session(:access_token)
    |> delete_session(:refresh_token)
    |> redirect(external: Utils.get_app_url())
  end

  def new_password_reset_request(conn, _) do
    %{"email" => email} = conn.body_params
    Accounts.create_new_password_reset_request(email)
    :ok
  end

  def confirm_password_reset_request(%Plug.Conn{} = conn, _) do
    %{"code" => code, "password" => password} = conn.body_params

    case Accounts.confirm_password_reset_request(code, password) do
      {:ok, _} ->
        :ok

      error ->
        error
    end
  end
end
