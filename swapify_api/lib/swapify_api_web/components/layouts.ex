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
    <main class="min-h-[100vh] relative flex w-full flex-col items-start justify-start md:flex-row">
      <nav class="sticky top-0 left-0 flex h-16 w-full shrink-0 flex-row items-center justify-between border-b border-solid border-b-gray-200 bg-white px-4 md:h-[100vh] md:w-[280px] md:border-b-[0px] md:flex-col md:items-start md:justify-start md:pb-4">
        <button id="menu-toggle" class="block md:hidden" type="button">
          <Lucide.menu stroke-width={1} width="32" height="32" />
        </button>

        <a href={~p"/admin"} class="text-xl font-bold md:block md:py-4">
          Swapify
        </a>

        <div
          id="nav-menu"
          class="invisible fixed top-0 left-0 z-20 h-full w-full bg-gray-900 bg-opacity-75 md:visible md:static"
        >
          <div class="max-w-[80%] flex h-full w-full flex-1 flex-col justify-between bg-white p-4 md:max-w-full md:p-0">
            <ul class="flex w-full flex-col items-start justify-start md:flex-1">
              <.nav_item href={~p"/admin"}>
                Dashboard
              </.nav_item>

              <.nav_item href={~p"/admin/users"}>
                Users
              </.nav_item>
            </ul>

            <.button as="a" size="sm" full_width href={~p"/admin/signout"}>
              Sign out
            </.button>
          </div>
        </div>
      </nav>

      <div class="w-full flex-1 p-4">
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
