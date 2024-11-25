defmodule SwapifyApiWeb.ErrorJSON do
  def form(assigns), do: %{errors: %{form: assigns.errors}}

  def error(assigns), do: ErrorMessage.to_jsonable_map(assigns.error)

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
