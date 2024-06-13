defmodule SwapifyApiWeb.AuthController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts.Services, as: AccountServices

  def sign_up(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    with {:ok, _} <- AccountServices.SignUpNewUser.call(data) do
      conn
      |> put_status(200)
      |> render(:signup)
    end
  end

  def sign_in(%Plug.Conn{} = conn, _) do
    data = conn.body_params

    case AccountServices.SignInUser.call(data["email"], data["password"]) do
      {:ok, user, access_token, refresh_token} ->
        conn
        |> put_status(200)
        |> render(:signin, access_token: access_token, refresh_token: refresh_token, user: user)

      error ->
        error
    end
  end
end
