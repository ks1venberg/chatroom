defmodule ChatroomWeb.Live.IndexLive do

  use ChatroomWeb, :live_view

  alias ChatroomWeb.Live.Components

  # need to put current_chat_id in LiveView connection
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_chat_id: nil)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="w-full border shadow bg-white">
        <div class="flex">
          <.live_component module={Components.ChatList} id="chat_list" current_user={@current_user}/>
          <.live_component module={Components.Messages} id="chat_messages" chat_id={@current_chat_id}/>
        </div>
      </div>
    """
  end

  @impl true
  def handle_event("join-chat", %{"id" => chat_id} = _event, socket) do
    {:noreply, assign(socket, current_chat_id: chat_id)}
  end

end
