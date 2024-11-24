defmodule SwapifyApiWeb.Layouts do
  use SwapifyApiWeb, :html

  embed_templates "layouts/*"

  slot :inner_block, required: true
  attr :href, :string, required: true

  defp nav_item(assigns) do
    ~H"""
    <li class='px-4 py-2 w-full'>
      <.link class='inline-block'>
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
    <main class='w-full'>
      <nav class="w-full h-16 border border-solid border-neutral-200 px-4 flex flex-row justify-between items-center relative">
        <a href={~p"/admin"} class="text-xl font-bold">
          Swapify
        </a>

        <ul id='nav-menu' class="flex flex-col justify-start items-center w-full absolute top-full left-0 right-0 bg-gray-50 invisible md:flex-row md:static md:w-fit md:visible">
          <.nav_item href={~p"/admin"}>
            Dashboard
          </.nav_item>

          <.nav_item href={~p"/admin"}>
            Users
          </.nav_item>

          <li class="w-full">
            <.button as="a" size="sm" full_width href={~p"/admin/signout"}>
              Sign out
            </.button>
          </li>
        </ul>

        <button id='menu-toggle' class='block md:hidden' type="button">
          <Lucide.menu_square stroke-width={1} width="32" height="32"/>
        </button>
      </nav>

      <div class="max-w-[1100px] min-h-[100vh] mx-auto p-4">
        <%= @inner_content %>
      </div>
    </main>
    """
  end
end
