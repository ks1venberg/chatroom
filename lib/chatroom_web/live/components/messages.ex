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

  def update(%{id: id, current_user: current_user, chat_id: chat_id} = _assigns, socket) do

    {:ok, socket
    |> assign(
      id: id,
      chat: Chats.get_chat_by_id!(chat_id),
      recieved_chat_id: false,
      messages: [],
      current_user: current_user)
    |> push_event("get_localstorage_msgs", %{chat_id: chat_id})}
  end

  @impl true
  def update(%{new_message: message} = _assigns, socket) do
    {:ok, socket
      |> assign(messages: [message | socket.assigns.messages] |> Enum.reverse())
      |> push_event(
        "new_message",
        %{
          chat_id: socket.assigns.chat.id,
          message: message
        }
      )}
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
      <div id={@id} class="w-full flex flex-col" phx-hook="GetAllChatMessages">
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
        <!-- Messages -->
        <div class="px-6 py-4 flex-1">
          <%= for message <- @messages do %>
            <div class="container mt-2">
              <div class="flex items-start">
                <span class="font-bold text-md mr-2 font-sans"><%= hd(String.split(message["user_email"], "@")) %></span>
                <span class="font-400 text-md text-gray-800 ml-4"><%= message["body"] %></span>
              <div class="float-right ml-10 overflow-hidden">
                <span class="text-s text-gray-400"><%= message["timestamp"] |> DateTime.to_naive()|> NaiveDateTime.truncate(:second)|> NaiveDateTime.to_string() %></span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
        <!-- Form for sending message-->
        <.simple_form for={%{}} as={:message} phx-submit="submit" phx-target={@myself}>
          <div class="flex m-4 rounded-lg overflow-hidden">
            <span class ="text-xl text-gray-500 mt-4 mr-2 border-gray-500"><%= "send" %></span>
            <.input name="body" field={{:message, :body}} value="" id="message_body" />
          </div>
        </.simple_form>

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

  @impl true
  def handle_event("submit", %{"body" => message_body}, socket) do
    if String.trim(message_body) == "" do
      {:noreply, socket}
    else
      message = %{
        "user_email" => socket.assigns.current_user.email,
        "timestamp" => DateTime.now!("Etc/UTC"),
        "body" => message_body
      }

      Phoenix.PubSub.broadcast(
        Chatroom.PubSub,
        "chats",
        {:messages, socket.assigns.chat.id, message}
      )

      {:noreply, socket |> push_event("clear_msg_input", %{field_id: "message_body"})}
    end
  end

  def handle_event("get_chat_msgs", nil, socket) do
    {:noreply, socket |> assign(messages: [])}
  end

  def handle_event("get_chat_msgs", messages, socket) do
    {:noreply, socket |> assign(messages: messages)}
  end

end
