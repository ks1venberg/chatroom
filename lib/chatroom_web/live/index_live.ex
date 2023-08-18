defmodule ChatroomWeb.Live.IndexLive do

  use ChatroomWeb, :live_view
  alias ChatroomWeb.Live.Components

  require Logger

  # need to put current_chat_id in LiveView connection
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Chatroom.PubSub, "chats")

    {:ok, assign(socket, current_chat_id: nil)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="w-full border shadow bg-white">
        <div class="flex">
          <.live_component module={Components.ChatList} id="chat_list" current_user={@current_user} current_chat_id={@current_chat_id}/>
          <.live_component module={Components.Messages} id="messages" current_user={@current_user} chat_id={@current_chat_id}/>
        </div>
      </div>
    """
  end

  # Event of click on chat name in ChatList menu
  @impl true
  def handle_event("connect_to_chat", %{"id" => chat_id} = _event, socket) do
    Logger.info("IndexLive, connect_to_chat: #{chat_id}
    \n socket #{inspect(socket, pretty: true)}")
    {:noreply, assign(socket, current_chat_id: chat_id)}
  end

  @impl true
  def handle_info({:message, chat_id, message} = assigns, socket) do

    Logger.info("IndexLive, handle_info_message  chat_id: #{chat_id}, \n new assigns #{inspect(assigns, pretty: true)} socket.assigns: #{inspect(socket.assigns, pretty: true)}")

    # We choose the chat to send message if there are different chats opened
    # if more than 1 user has connected, each of them has own current_chat_id and socket state

    socket_chat_id = String.to_integer(socket.assigns.current_chat_id)


    if chat_id == socket_chat_id do
      send_update(Components.Messages, id: "messages", chat_id: socket_chat_id, recieve_new_message: message)
    else
      send_update(Components.ChatList, id: "chat_list", current_user: socket.assigns.current_user, current_chat_id: chat_id)
      send_update(Components.Messages, id: "messages", chat_id: chat_id, recieve_new_message: message)
    end

    {:noreply, socket}
  end

end
