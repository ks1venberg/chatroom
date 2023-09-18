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

  def update(%{id: id, current_user: current_user, chat_id: chat_id}, socket) do

    current_chat_id = if is_integer(chat_id), do: Integer.to_string(chat_id), else: chat_id

    {:ok, socket
      |> assign(
      id: id,
      chat: Chats.get_chat_by_id!(chat_id),
      recieved_chat_id: false,
      messages: [],
      current_chat_id: current_chat_id,
      current_user: current_user)
      |> push_event("get_localstorage_msgs", %{chat_id: chat_id})}
  end

  @impl true
  def update(%{chat_id: chat_id, recieve_new_message: message}, socket) do

    current_chat_id = if is_integer(chat_id), do: Integer.to_string(chat_id), else: chat_id

      {:ok, socket
        |> assign(
          chat: Chats.get_chat_by_id!(chat_id),
          messages: [message | socket.assigns.messages] |> Enum.sort(&(&1["dt_unix"] >= &2["dt_unix"])),
          current_chat_id: current_chat_id)
        |> push_event(
          "js_save_new_message",
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
     Click on chat name to start messaging
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

  @impl true
  def handle_event("submit", %{"body" => message_body}, socket) do

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

      {:noreply, socket |> push_event("clear_input_field", %{field_id: "message_body"})}
    end
  end

  @impl true
  def handle_event("recieve_new_message", nil, socket) do
    {:noreply, socket |> assign(messages: [])}
  end

  # Puts messages array in socket.assigns with sorting it by timestamp
  @impl true
  def handle_event("recieve_new_message", messages, socket) do
    {:noreply, socket |> assign(messages: messages |> Enum.sort(&(&1["dt_unix"] >= &2["dt_unix"])))}
  end

end
