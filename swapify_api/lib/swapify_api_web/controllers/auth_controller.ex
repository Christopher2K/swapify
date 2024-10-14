defmodule SwapifyApiWeb.AuthController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts.Services, as: AccountServices
  alias SwapifyApi.Accounts

  def sign_up(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    with {:ok, user} <- AccountServices.SignUpNewUser.call(data) do
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
end
