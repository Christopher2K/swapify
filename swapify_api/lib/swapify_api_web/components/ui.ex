defmodule SwapifyApiWeb.UI do
  use Phoenix.Component

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :rest, :global

  def h1(assigns),
    do: ~H"""
    <h1 class={"text-2xl font-medium #{@class}"} {@rest}>
      <%= render_slot(@inner_block) %>
    </h1>
    """

  slot :inner_block, required: true
  attr :size, :string, values: ["sm", "md"], default: "md"
  attr :full_width, :boolean, default: false
  attr :as, :string, values: ["button", "a"], default: "button"
  attr :rest, :global

  def button(assigns),
    do: ~H"""
    <.dynamic_tag name={@as} class={[
      "w-full inline-flex flex-row justify-center items-center font-medium bg-neutral-950 text-neutral-50 rounded-md whitespace-nowrap",
      button_size(@size),
      if(@full_width, do: "w-full", else: "")
    ]} {@rest}>
      <%= render_slot(@inner_block) %>
    </.dynamic_tag>
    """

  defp button_size(size) do
    case(size) do
      "sm" -> "py-1 px-2 text-base"
      "md" -> "py-2 px-4 text-lg"
    end
  end
end
