defmodule SwapifyApiWeb.FallbackController do
  @doc """
  Fallback controller that handle everything controllers don't
  """
  require Logger

  use Phoenix.Controller

  def call(conn, {:ok}) do
    conn
    |> put_status(200)
    |> put_view(json: SwapifyApiWeb.SuccessJSON)
    |> render(:"200")
  end

  def call(conn, :ok) do
    conn
    |> put_status(200)
    |> put_view(json: SwapifyApiWeb.SuccessJSON)
    |> render(:"200")
  end

  def call(conn, {:error, %Ecto.Changeset{errors: errors}}) do
    errors_map =
      Enum.reduce(errors, %{}, fn {key, {message, _}}, errors_map ->
        Map.put(errors_map, Atom.to_string(key), message)
      end)

    conn
    |> put_status(422)
    |> put_view(json: SwapifyApiWeb.ErrorJSON)
    |> render(:form, errors: errors_map)
  end

  def call(conn, {:error, %ErrorMessage{code: code} = error}) do
    conn
    |> put_status(code)
    |> put_layout(html: {SwapifyApiWeb.Layouts, :error})
    |> put_view(json: SwapifyApiWeb.ErrorJSON, html: SwapifyApiWeb.ErrorHTML)
    |> render(:error, error: error, user_id: conn.assigns[:user_id])
    |> halt()
  end

  def call(%Plug.Conn{} = conn, error) do
    Logger.error("Unknown error occurred", error: error)

    conn
    |> put_status(500)
    |> json(
      ErrorMessage.to_jsonable_map(
        ErrorMessage.internal_server_error("An  error occurred. Please try again.")
      )
    )
  end
end
