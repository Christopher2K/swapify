defmodule SwapifyApiWeb.Layouts do
  use SwapifyApiWeb, :html

  embed_templates "layouts/*"

  slot :inner_block, required: true
  attr :href, :string, required: true

  defp nav_item(assigns) do
    ~H"""
    <li class="w-full px-4 py-2">
      <.link class="inline-block" href={@href}>
        <%= render_slot(@inner_block) %>
      </.link>
    </li>
    """
  end

  def app(assigns) do
    ~H"""
    <main class="max-w-[1100px] min-h-[100vh] mx-auto px-4">
      <%= @inner_content %>
    </main>
    """
  end

  def admin(assigns) do
    ~H"""
    <main class="min-h-[100vh] w-full">
      <nav class="relative flex h-16 w-full flex-row items-center justify-between border border-solid border-neutral-200 px-4">
        <a href={~p"/admin"} class="text-xl font-bold">
          Swapify
        </a>

        <ul
          id="nav-menu"
          class="invisible absolute top-full right-0 left-0 flex w-full flex-col items-center justify-start bg-gray-50 md:visible md:static md:w-fit md:flex-row"
        >
          <.nav_item href={~p"/admin"}>
            Dashboard
          </.nav_item>

          <.nav_item href={~p"/admin/users"}>
            Users
          </.nav_item>

          <li class="w-full">
            <.button as="a" size="sm" full_width href={~p"/admin/signout"}>
              Sign out
            </.button>
          </li>
        </ul>

        <button id="menu-toggle" class="block md:hidden" type="button">
          <Lucide.menu_square stroke-width={1} width="32" height="32" />
        </button>
      </nav>

      <div class="max-w-[1100px] mx-auto p-4">
        <%= @inner_content %>
      </div>
    </main>
    """
  end

  def error(assigns) do
    ~H"""
    <main class="h-[100vh] flex w-full flex-col items-center justify-center">
      <%= @inner_content %>
    </main>
    """
  end
end
