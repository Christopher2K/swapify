defmodule SwapifyApiWeb.Forms do
  use Phoenix.Component

  attr :label, :string
  attr :name, :string
  slot :inner_block, required: true

  def form_field(assigns),
    do: ~H"""
    <div class="flex w-full flex-shrink-0 flex-col items-start justify-start gap-2">
      <label for={@name} class="w-full text-base font-medium"><%= @label %></label>
      <%= render_slot(@inner_block) %>
    </div>
    """

  attr :rest, :global, include: ~w(name)
  attr :type, :string, default: "text", values: ["text", "password", "email"]

  def text_input(assigns),
    do: ~H"""
    <input {@rest} type={@type} class="w-full rounded-md border-neutral-200 px-2 py-2" />
    """

  attr :rest, :global, include: ~w(name)
  attr :options, :list, required: true
  attr :value, :string, required: false

  def select_input(assigns),
    do: ~H"""
    <select {@rest} class="w-full rounded-md border-neutral-200 px-2 py-2" value={@value}>
      <%= for {name, value} <- @options do %>
        <option value={value} selected={value == @value}><%= name %></option>
      <% end %>
    </select>
    """
end
