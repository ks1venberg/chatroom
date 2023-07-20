defmodule ChatroomWeb.Live.Components.Messages do
  @moduledoc """
  Messages component
  """
  use ChatroomWeb, :live_component

  require Logger

  alias Chatroom.Chats
  alias ChatroomWeb.Live.JoinChatLive
  alias ChatroomWeb.Router.Helpers, as: Routes

  @impl true
  def update(%{chat_id: nil} = _assigns, socket) do
    {:ok, assign(socket, chat: nil)}
  end

  @impl true
  def update(%{chat_id: chat_id} = _assigns, socket) do
    {:ok, assign(socket, chat: Chats.get_chat_by_id!(chat_id), recieved_chat_id: false)}
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
            <div class="text-gray-400 text-sm link">
              chat_id: <%= @chat.id %>
              <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 inline" fill="none"
                  viewBox="0 0 24 24" stroke="currentColor"
                  phx-click="connect_by_chat_id"
                  phx-value-chat_id={@chat.id}
                  phx-target={@myself}>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
              <%= if @recieved_chat_id do %>
                link to join: <%= @link %>
              <% end %>
          </div>
          </div>
        </div>
      </div>
    """
  end

  # route can be done by LiveView helper 'live_path'
  @impl true
  def handle_event("connect_by_chat_id", %{"chat_id" => chat_id} = _assigns, socket) do

    # ChatroomWeb.Router.Helpers.live_path(ChatroomWeb.Endpoint, ChatroomWeb.Live.JoinChatLive, "2")
    # "/chats/2"

    link = ChatroomWeb.Endpoint.url() <> Routes.live_path(ChatroomWeb.Endpoint, JoinChatLive, "#{chat_id}")

    Logger.info("LINK to join chat: #{link}")

    {:noreply,
     socket
     |> assign(recieved_chat_id: true, link: link)
     |> push_event("connect_by_chat_id", %{link: link})}
  end

end
