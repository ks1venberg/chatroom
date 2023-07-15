defmodule ChatroomWeb.Live.Components.Messages do
  @moduledoc """
  Messages component
  """
  use ChatroomWeb, :live_component

  alias Chatroom.Chats

  @impl true
  def update(%{chat_id: nil} = _assigns, socket) do
    {:ok, assign(socket, chat: nil)}
  end

  @impl true
  def update(%{chat_id: chat_id} = _assigns, socket) do
    {:ok, assign(socket, chat: Chats.get_chat_by_id!(chat_id))}
  end

  @impl true
  def render(%{chat: nil} = assigns) do
    ~H"""
    <div class="w-full flex flex-col px-1 py-1">
     No messages yet. Let's create it!
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="w-full flex flex-col">
        <div class="border-b flex px-6 py-2 items-center">
          <div class="flex flex-col">
            <h3 class="text-gray-800 text-md mb-1 font-extrabold"><%= @chat.name %></h3>
              <div class="text-gray-700 text-sm">
                Here could be a description
              </div>
          </div>
        </div>
      </div>
    """
  end

end
