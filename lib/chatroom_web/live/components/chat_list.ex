defmodule ChatroomWeb.Live.Components.ChatList do
  @moduledoc """
  Left menu with chats
  """
  use ChatroomWeb, :live_component
  require Logger
  alias Chatroom.Chats
  alias Chatroom.Repo

  @doc """
  Update initial
  """
  @impl true
  def update(%{current_user: current_user, current_chat_id: nil}, socket) do
    {:ok,
     assign(socket,
      current_user: current_user,
      current_chat_id: nil,
      user_chats: Chats.get_user_chats(current_user),
      all_chats: Chats.get_all()
     )}
  end

  # Update in dialog
  @impl true
  def update(%{current_user: current_user, current_chat_id: current_chat_id}, socket) do

    {:ok,
     assign(socket,
      current_user: current_user,
      current_chat_id: current_chat_id,
      user_chats: Chats.get_user_chats(current_user),
      all_chats: Chats.get_all()
     )}
  end

  # when a new chat created
  @impl true
  def update(%{user_id: user_id, new_chat_id: new_chat_id} = assigns, socket) do
    Logger.debug("ChatList, update - new chat: #{inspect(assigns, pretty: true)}, current_chat_id: #{inspect(socket.assigns.current_chat_id)}
    ")

    Phoenix.PubSub.broadcast(Chatroom.PubSub, "chats", {:chat, new_chat_id, user_id})

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-violet-700 text-gray w-1/2 pb-6 md:block">
      <h1 class="text-white text-xl mb-2 mt-3 px-4 font-sans flex justify-between"></h1>
        <div class="px-4 mb-2 font-sans font-bold text-white text-center">Available Chats</div>
        <div class="bg-violet-700 pl-6 mb-6 py-1 text-white font-semi-bold", style="padding-left: 5px">
          <%= for chat <- @all_chats do %>
            <div class={if "#{chat.id}" == @current_chat_id, do: "bg-blue-500", else: ""}, style="padding-left: 0px">
                <a onmouseover="this.style.cursor='pointer'" class="link" phx-click="connect_to_chat" phx-value-id={chat.id}>
                  <span class="text-gray-400"></span><%= chat.name %>
                </a>
            </div>
          <% end %>
            <.simple_form for={%{}} as={:chat} id={"chat_list-#{@myself}"} phx-submit="create-chat" phx-target={@myself} phx-hook="NewChat">
              <div class="flex-none ml-2 rounded-lg overflow-hidden">
                <.input name="new_chat_name" type="text" field={{:chat, :name}} id="new_chat_id" value="" placeholder="new chat name"/>
              </div>
                <.button class="flex-none -mt-3 mb-3 ml-2 -mr-2 opacity-50 hover:opacity-70">create chat</.button>
            </.simple_form>
        </div>
    </div>
    """
  end

  @doc """
  Event on chat creation
  """
  @impl true
  def handle_event("create-chat", %{"new_chat_name" => chat_name}, socket) do
    Logger.debug("ChatList, handle_create-chat: #{chat_name}")

    case Chatroom.Chats.create_chat(%{name: chat_name, user_id: socket.assigns.current_user.id}) do
      {:ok, chat} ->
        {:noreply,
          socket
          |> push_event("clear_input_field", %{field_id: "new_chat_id"})
          |> push_event("chat_created", %{new_chat_id: chat.id, user_id: chat.user_id})}
      {:error, %Ecto.Changeset{} = changeset} ->
        Repo.insert(changeset)
        {:noreply, socket}
    end
  end

end
