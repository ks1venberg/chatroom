defmodule ChatroomWeb.Live.JoinChatLive do
  @moduledoc """
  Joining the chat for users
  """
  use ChatroomWeb, :live_view
  require Logger

  alias Chatroom.Chats

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"chat_id" => chat_id} = _params, _url, %{assigns: %{current_user: user}} = socket) do
    chat = Chats.get_chat_by_id!(chat_id)
    {:ok, chat} = Chats.add_user(user, chat)

    Logger.info("JoinChatLive: #{chat_id},chat: #{inspect(chat, pretty: true)}")

    send_update(Components.ChatList, id: "chat_list", current_user: user, current_chat_id: chat_id)

    {:noreply,
    socket
          |> Phoenix.LiveView.redirect(to: "/")
          |> put_flash(:info, "Chat #{chat.name} connected!")
          |> assign(current_chat_id: chat_id)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    """
  end
end
