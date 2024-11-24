defmodule SwapifyApiWeb.AdminAuthController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.Accounts

  def sign_in(conn, _), do: conn |> render(:signin)

  def sign_in_form(conn, %{"email" => email, "password" => password}) do
    with {
           :ok,
           _,
           access_token,
           refresh_token
         } <- Accounts.sign_in_user(email, password) do
      conn
      |> put_session(:access_token, access_token)
      |> put_session(:refresh_token, refresh_token)
      |> redirect(to: ~p"/admin")
    else
      _ ->
        conn
        |> put_flash(:error, "Incorrect credentials.")
        |> render(:signin)
    end
  end

  def sign_out(conn, _),
    do:
      conn
      |> delete_session(:access_token)
      |> delete_session(:refresh_token)
      |> redirect(to: ~p"/admin/signin")
end
