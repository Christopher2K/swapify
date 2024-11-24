defmodule SwapifyApiWeb.Forms do
  use Phoenix.Component

  attr :label, :string
  attr :name, :string
  slot :inner_block, required: true

  def form_field(assigns),
    do: ~H"""
    <div class='w-full flex flex-col justify-start items-start gap-2'>
      <label for={@name} class='w-full font-medium text-base'><%= @label %></label>
      <%= render_slot(@inner_block) %>
    </div>
    """

  attr :rest, :global, include: ~w(name)
  attr :type, :string, default: "text", values: ["text", "password", "email"]

  def text_input(assigns),
    do: ~H"""
    <input {@rest} type={@type} class="w-full px-2 py-2 rounded-md border-neutral-200" />
    """
end
