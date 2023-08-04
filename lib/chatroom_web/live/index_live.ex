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

  @impl true
  def handle_event("connect_to_chat", %{"id" => chat_id} = _event, socket) do
    Logger.info("ChatroomWeb.Live.IndexLive, connect_to_chat: #{chat_id} messages:#{inspect(Map.get(socket.assigns, :messages), pretty: true)}")
    Logger.info("ChatroomWeb.Live.IndexLive, socket #{inspect(socket, pretty: true)}")
    {:noreply, assign(socket, current_chat_id: chat_id)}
  end

  @impl true
  def handle_info({:message, chat_id, message}, socket) do
    current_chat = socket.assigns.current_chat_id
    if current_chat && chat_id == String.to_integer(current_chat) do
      send_update(Components.Messages, id: "messages", recieve_new_message: message)
    end
    {:noreply, socket}
  end

end
