defmodule ChatroomWeb.Live.Components.ChatList do
  @moduledoc """
  Left menu with chats
  """
  use ChatroomWeb, :live_component

  alias Chatroom.Chats

  @impl true
  def update(%{current_user: current_user, current_chat_id: current_chat_id} = _assigns, socket) do
    {:ok,
     assign(socket,
       current_user: current_user,
       current_chat_id: current_chat_id,
       user_chats: Chats.get_user_chats(current_user)
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-blue-800 text-indigo-200 w-1/2 pb-6 md:block">
      <h1 class="text-white text-xl mb-2 mt-3 px-4 font-sans flex justify-between">
      </h1>
      <div class="px-4 mb-2 font-sans">Available Chats</div>
      <div class="bg-teal-600 pl-6 mb-6 py-1 text-white font-semi-bold", style="padding-left: 5px">
        <%= for chat <- @user_chats do %>
          <div class={if "#{chat.id}" == @current_chat_id, do: "bg-blue-500", else: ""}>
            <li>
              <a onmouseover="this.style.cursor='pointer'" class="link" phx-click="join-chat" phx-value-id={chat.id}>
                <span class="text-gray-400"></span><%= chat.name %>
              </a>
            </li>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
