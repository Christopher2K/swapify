defmodule SwapifyApi.Plugs.Authenticated do
  @moduledoc """
  Plug that protects authenticated endpoints
  """
  alias OpenTelemetry.Tracer
  alias SwapifyApi.Accounts.Token

  import Plug.Conn

  def init(nil), do: [roles: [:beta, :user, :admin]]
  def init([]), do: [roles: [:beta, :user, :admin]]
  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, opts) do
    roles = Keyword.get(opts, :roles) |> Enum.map(&Atom.to_string/1)

    case get_session(conn, :access_token) do
      nil ->
        Tracer.set_attribute("user.id", nil)
        halt_request(conn)

      access_token ->
        with {:ok, %{"user_id" => user_id, "user_email" => user_email, "user_role" => user_role}} <-
               Token.verify_and_validate(access_token),
             true <- user_role in roles do
          Tracer.set_attribute("user.id", user_id)

          conn
          |> assign(:user_id, user_id)
          |> assign(:user_email, user_email)
          |> assign(:user_role, user_role)
        else
          _ ->
            halt_request(conn)
        end
    end
  end

  defp halt_request(conn),
    do:
      SwapifyApiWeb.FallbackController.call(
        conn,
        {:error, ErrorMessage.unauthorized("Unauthorized")}
      )
end
