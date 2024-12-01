defmodule SwapifyApiWeb.UI do
  use Phoenix.Component

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(id class)

  def h1(assigns),
    do: ~H"""
    <h1 class={"#{@class} text-2xl font-medium"} {@rest}>
      <%= render_slot(@inner_block) %>
    </h1>
    """

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(id class)

  def h2(assigns),
    do: ~H"""
    <h2 class={"#{@class} text-xl font-medium"} {@rest}>
      <%= render_slot(@inner_block) %>
    </h2>
    """

  slot :inner_block, required: true
  attr :size, :string, values: ["sm", "md"], default: "md"
  attr :full_width, :boolean, default: false
  attr :as, :string, values: ["button", "a"], default: "button"
  attr :rest, :global, include: ~w(href)

  def button(assigns),
    do: ~H"""
    <.dynamic_tag
      name={@as}
      class={[
        "w-full inline-flex flex-row justify-center items-center font-medium bg-neutral-950 text-neutral-50 rounded-md whitespace-nowrap",
        button_size(@size),
        if(@full_width, do: "w-full", else: "")
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.dynamic_tag>
    """

  defp button_size(size) do
    case(size) do
      "sm" -> "py-1 px-2 text-base"
      "md" -> "py-2 px-4 text-lg"
    end
  end

  slot :inner_block, required: true
  attr :rest, :global, include: ~w(id class)

  def th(assigns),
    do: ~H"""
    <th class="p-2 text-left text-sm font-bold">
      <%= render_slot(@inner_block) %>
    </th>
    """

  slot :inner_block, required: true
  attr :rest, :global, include: ~w(id class)

  def td(assigns),
    do: ~H"""
    <td class="p-2">
      <%= render_slot(@inner_block) %>
    </td>
    """

  def description_list(assigns) do
    ~H"""
    <dl class="flex-start flex flex-col items-start gap-2">
      <%= for {title, value} <- @items do %>
        <div class="flex w-full flex-col items-start justify-start">
          <dt class="text-sm font-bold"><%= title %></dt>
          <dd><%= value %></dd>
        </div>
      <% end %>
    </dl>
    """
  end

  attr :name, :string, required: true
  attr :value, :string, required: true

  def card_metric(assigns) do
    ~H"""
    <div class="flex flex-col items-start justify-start gap-2 rounded-lg border border-solid border-gray-200 bg-white px-4 py-2">
      <p class="w-full text-center text-xs"><%= @name %></p>
      <p class="w-full text-center text-lg font-medium"><%= @value %></p>
    </div>
    """
  end
end
