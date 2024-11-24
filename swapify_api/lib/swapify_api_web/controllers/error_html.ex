defmodule SwapifyApiWeb.ErrorHTML do
  use SwapifyApiWeb, :html

  def error(assigns) do
    ~H"""
    <div class='w-full flex flex-col justify-center items-center gap-10'>

      <.h1>An error happened!</.h1>

      <p class='text-xl'><%= @error.message %></p>

      <div class='max-w-40 flex flex-col justify-center items-center gap-4'>
        <%= if @user_id do %>
          <.button as='a' href={~p"/admin"}>Back to dashboard</.button>
        <% else %>
          <.button as='a' href={~p"/admin/signin"}>Back to sign in page</.button>
        <% end %>
      </div>
    </div>
    """
  end
end
