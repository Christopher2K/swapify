defmodule SwapifyApiWeb.SuccessJSON do
  def render("200.json", _) do
    %{data: "ok"}
  end
end
