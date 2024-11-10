defmodule SwapifyApi.Plugs.Authenticated do
  @moduledoc """
  Plug that protects authenticated endpoints
  """
  use OpenTelemetryDecorator

  alias SwapifyApi.Accounts.Token

  import Plug.Conn

  def init(default), do: default

  @decorate with_span("plug.authenticated")
  def call(%Plug.Conn{} = conn, _) do
    case get_session(conn, :access_token) do
      nil ->
        O11y.set_attribute("user.id", nil)
        halt_request(conn)

      access_token ->
        case Token.verify_and_validate(access_token) do
          {:ok, %{"user_id" => user_id, "user_email" => user_email}} ->
            O11y.set_attribute("user.id", user_id)

            conn
            |> assign(:user_id, user_id)
            |> assign(:user_email, user_email)

          _ ->
            halt_request(conn)
        end
    end
  end

  defp halt_request(conn) do
    %{code: code} = error = ErrorMessage.unauthorized("Unauthorized")

    conn
    |> put_status(code)
    |> Phoenix.Controller.json(ErrorMessage.to_jsonable_map(error))
    |> halt()
  end
end
