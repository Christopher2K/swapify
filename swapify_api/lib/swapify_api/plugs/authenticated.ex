defmodule SwapifyApi.Plugs.Authenticated do
  @moduledoc """
  Plug that protects authenticated endpoints
  """
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.Accounts
  alias OpenTelemetry.Tracer
  alias SwapifyApi.Accounts.Token

  import Plug.Conn

  def init(nil), do: [roles: [:beta, :user, :admin]]
  def init([]), do: [roles: [:beta, :user, :admin]]
  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, opts) do
    roles = Keyword.get(opts, :roles) |> Enum.map(&Atom.to_string/1)

    with access_token when is_binary(access_token) <- get_session(conn, :access_token),
         refresh_token when is_binary(refresh_token) <- get_session(conn, :refresh_token) do
      case Token.verify_and_validate(access_token) do
        {:ok, %{"user_id" => user_id, "user_email" => user_email, "user_role" => user_role}} ->
          Tracer.set_attribute("user.id", user_id)

          if user_role in roles do
            conn
            |> assign(:user_id, user_id)
            |> assign(:user_email, user_email)
            |> assign(:user_role, user_role)
          else
            halt_request(conn)
          end

        {:error, kw} when is_list(kw) ->
          Tracer.set_attribute("user.id", nil)

          if Keyword.get(kw, :claim) == "exp" do
            refresh_session(conn, refresh_token)
          else
            halt_request(conn)
          end

        _ ->
          conn
          |> delete_session(:access_token)
          |> delete_session(:refresh_token)
          |> halt_request()
      end
    else
      _ ->
        Tracer.set_attribute("user.id", nil)
        halt_request(conn)
    end
  end

  defp refresh_session(conn, refresh_token) do
    with {:ok, %{"user_id" => user_id, "user_email" => user_email, "user_role" => user_role}} <-
           Token.verify_and_validate(refresh_token),
         user <- %User{
           id: user_id,
           email: user_email,
           role: user_role
         },
         {:ok, _, access_token, refresh_token} <- Accounts.genereate_auth_tokens(user) do
      conn
      |> put_session(:access_token, access_token)
      |> put_session(:refresh_token, refresh_token)
      |> assign(:user_id, user_id)
      |> assign(:user_email, user_email)
      |> assign(:user_role, user_role)
    else
      _ ->
        conn
        |> delete_session(:access_token)
        |> delete_session(:refresh_token)
        |> halt_request()
    end
  end

  defp halt_request(conn),
    do:
      SwapifyApiWeb.FallbackController.call(
        conn,
        {:error, ErrorMessage.unauthorized("Unauthorized")}
      )
end
