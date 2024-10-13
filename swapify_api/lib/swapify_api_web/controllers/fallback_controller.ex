defmodule SwapifyApiWeb.FallbackController do
  @doc """
  Fallback controller that handle everything controllers don't
  """
  use Phoenix.Controller

  def call(conn, {:error, %Ecto.Changeset{errors: errors}}) do
    errors_map =
      Enum.reduce(errors, %{}, fn {key, {message, _}}, errors_map ->
        Map.put(errors_map, Atom.to_string(key), message)
      end)

    conn
    |> put_status(422)
    |> put_view(json: SwapifyApiWeb.ErrorJSON)
    |> render("forms.json", errors: errors_map)
  end

  def call(conn, {:error, reason}) do
    {code, message} = SwapifyApi.Errors.get_details(reason)

    conn
    |> put_status(code)
    |> put_view(json: SwapifyApiWeb.ErrorJSON)
    |> render("errors.json", message: message)
  end

  def call(conn, _) do
    {code, message} = SwapifyApi.Errors.get_details(nil)

    conn
    |> put_status(code)
    |> put_view(json: SwapifyApiWeb.ErrorJSON)
    |> render("errors.json", message: message)
  end

  def call(conn, {:ok}) do
    conn
    |> put_status(200)
    |> put_view(json: SwapifyApiWeb.SuccessJSON)
    |> render(:"200")
  end
end
