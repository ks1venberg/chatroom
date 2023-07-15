defmodule ChatroomWeb.Live.AuthLive do

  use ChatroomWeb, :live_view

  import Phoenix.LiveView

  alias Chatroom.Accounts
  alias Chatroom.Accounts.User

  def on_mount(:default, _params, %{"user_token" => token} = _session, socket) do
    case Accounts.get_user_by_session_token(token) do
      %User{} = user -> {:cont, assign(socket, current_user: user)}
      _notfound ->
        {:halt, redirect(socket, to: "/user/log_in")}
    end
  end

  def on_mount(:default, _params, _session, socket) do
    {:halt, redirect(socket, to: "/user/log_in")}
  end

  def render(assigns) do
    ~H"""
    """
  end

end
