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

  def update(%{id: id, current_user: current_user, chat_id: chat_id} = assigns, socket) do
    Logger.info("Messages update 0: \n new assigns: #{inspect(assigns, pretty: true)}, \n socket.assigns: #{inspect(socket.assigns, pretty: true)}")
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
  def update(%{chat_id: chat_id, recieve_new_message: message} = assigns, socket) do

    Logger.info("Messages update: #{inspect(message, pretty: true)}, \n new assigns: #{inspect(assigns, pretty: true)}, \n socket.assigns: #{inspect(socket.assigns, pretty: true)}")

      {:ok, socket
        |> assign(
          chat: Chats.get_chat_by_id!(chat_id),
          messages: [message | socket.assigns.messages] |> Enum.sort(&(&1["dt_unix"] >= &2["dt_unix"])),
          current_chat_id: chat_id)
        |> push_event(
          "jscall_new_message",
          %{
            chat_id: chat_id,
            message: message,
            field_id: "message_body"
          })
        |> push_event("get_localstorage_msgs", %{chat_id: chat_id})
      }

  end

  @impl true
  def render(%{chat: nil} = assigns) do
    ~H"""
    <div class="w-full flex flex-col px-1 py-1">
     click on chat name to start messaging
    </div>
    """
  end

  @impl true
  def render(assigns) do
      Logger.info("Messages render(assigns): #{inspect(assigns, pretty: true)}")
    ~H"""
      <div id={@id} class="w-full flex flex-col" phx-hook="GetAllChatMessages">
        <div class="border-b flex px-6 py-2 items-center">
          <div class="flex flex-col">
            <h3 class="text-gray-800 text-md mb-1 font-extrabold"><%= @chat.name %></h3>
            <div class="text-gray-400 text-sm link">
              Connect to this chat
              <svg xmlns="http://www.w3.org/2000/svg" onmouseover="this.style.cursor='pointer'" viewBox="0 2 24 24" class="w-6 h-6 inline mx-2" fill="Green" stroke="Green"
                phx-click="connect_by_chat_id"
                phx-value-chat_id={@chat.id}
                phx-target={@myself}>
                <path fill-rule="evenodd" d="M12 3.75a.75.75 0 01.75.75v6.75h6.75a.75.75 0 010 1.5h-6.75v6.75a.75.75 0 01-1.5 0v-6.75H4.5a.75.75 0 010-1.5h6.75V4.5a.75.75 0 01.75-.75z" clip-rule="evenodd" />
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
                <span class="text-s text-gray-400"><%=message["timestamp"]%>
                </span>
                </div>
              </div>
            </div>
          <% end %>
        </div>
        <!-- Form for sending message-->
        <.simple_form :let={_f} for={%{}} as={:message} phx-submit="submit" phx-target={@myself}>
          <div class="flex ml-4 rounded-lg overflow-hidden">
            <.input name="body" field={{:message, :body}} value="" id="message_body"/>
          </div>
          <:actions>
            <.button class="flex-none -mt-3 mb-3 ml-4 opacity-50 hover:opacity-70">send</.button>
          </:actions>
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

    {:noreply,
     socket
     |> assign(recieved_chat_id: true, link: link)
     |> push_event("connect_by_chat_id", %{link: link})}
  end

  @impl true
  def handle_event("submit", %{"body" => message_body} = assigns, socket) do

    Logger.info("Messages submit: #{inspect(assigns, pretty: true)}")

    if String.trim(message_body) == "" do
      {:noreply, socket}
    else
      dt = DateTime.now!("Etc/UTC") |> DateTime.truncate(:second)

      message = %{
        "user_email" => socket.assigns.current_user.email,
        "timestamp" => dt|> DateTime.to_naive() |> NaiveDateTime.to_string(),
        "dt_unix" => DateTime.to_unix(dt),
        "body" => message_body
      }

      Phoenix.PubSub.broadcast(
        Chatroom.PubSub,
        "chats",
        {:message, socket.assigns.chat.id, message}
      )
      Logger.info("Messages submit Phoenix.PubSub: #{inspect(socket.assigns, pretty: true)}")

      {:noreply, socket |> push_event("clear_input_field", %{field_id: "message_body"})}
    end
  end

  def handle_event("recieve_new_message", nil, socket) do
    {:noreply, socket |> assign(messages: [])}
  end

  # Puts messages array in socket.assigns with sorting it by timestamp
  def handle_event("recieve_new_message", messages, socket) do
    {:noreply, socket |> assign(messages: messages |> Enum.sort(&(&1["dt_unix"] >= &2["dt_unix"])))}
  end

end
