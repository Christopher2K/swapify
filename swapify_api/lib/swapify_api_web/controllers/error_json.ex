defmodule SwapifyApiWeb.ErrorJSON do
  def render("forms.json", assigns) do
    %{errors: %{form: assigns.errors}}
  end

  def render("error.json", assigns), do: ErrorMessage.to_jsonable_map(assigns.error)

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
