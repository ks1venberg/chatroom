defmodule ChatroomWeb.Live.IndexLive do

  use ChatroomWeb, :live_view
  alias ChatroomWeb.Live.Components
  alias Chatroom.Accounts

  require Logger

  # need to put current_chat_id in LiveView connection
  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :clear_flash, 3000)
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
  def handle_event("connect_to_chat", %{"id" => chat_id}, socket) do

    # We need to update both components - to activate new chat and to get proper messages with chat name
    send_update(Components.ChatList, id: "chat_list", current_user: socket.assigns.current_user, current_chat_id: chat_id)
    send_update(Components.Messages, id: "messages", current_user: socket.assigns.current_user, chat_id: chat_id)

    {:noreply, socket |> assign(current_chat_id: chat_id)}
  end

  @doc """
  Recieves new chat_id from js-event
  """
  @impl true
  def handle_event("update_chat_fromjs",  %{"new_chat_id" => chat_id, "user_id" => user_id} = params, socket) do

    Logger.debug("IndexLive: #{inspect(params, pretty: true)}
    \n current_chat_id #{inspect(socket.assigns.current_chat_id)} user.id:#{inspect(socket.assigns.current_user.id)}")

    send_update(Components.ChatList, id: "chat_list", user_id: user_id, new_chat_id: chat_id)

    {:noreply, socket}
  end

  @doc """
  Updates ChatList when new chat added; on update - we are keeping active current dialog
  """
  @impl true
  def handle_info({:new_chat, chat_name, user_id} = assigns, socket) do

    Logger.debug("IndexLive, handle_info_chat: #{inspect(assigns)}, current_chat_id: #{inspect(socket.assigns.current_chat_id)}")

    send_update(Components.ChatList, id: "chat_list", current_user: Accounts.get_user!(user_id), current_chat_id: socket.assigns.current_chat_id)

    if user_id != socket.assigns.current_user.id do
      Process.send_after(self(), :clear_flash, 3000)
      {:noreply, socket |> put_flash(:info, "Created new chat: #{chat_name}")}
    else
      {:noreply, socket}
    end

  end

  # Recieves message and then updates both components
  @impl true
  def handle_info({:message, chat_id, message}, socket) do

    # We choose the chat to send message if there are different chats opened
    # if more than 1 user has connected, each of them has own current_chat_id and socket state

    if id_to_str(chat_id) == socket.assigns.current_chat_id do
      send_update(Components.Messages, id: "messages", chat_id: socket.assigns.current_chat_id, recieve_new_message: message)
      # send_update(Components.ChatList, id: "chat_list", current_user: socket.assigns.current_user, current_chat_id: socket_chat_id)
    else
      send_update(Components.ChatList, id: "chat_list", current_user: socket.assigns.current_user, current_chat_id: id_to_str(chat_id))
      send_update(Components.Messages, id: "messages", chat_id: id_to_str(chat_id), recieve_new_message: message)
    end

    {:noreply, socket |> assign(current_chat_id: id_to_str(chat_id))}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end


  def id_to_str(id) do
    if is_integer(id), do: Integer.to_string(id), else: id
  end

end
