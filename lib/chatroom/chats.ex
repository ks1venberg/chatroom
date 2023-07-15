defmodule Chatroom.Chats do
  @moduledoc """
    DB logic for Chats context
  """
  import Ecto.Query, warn: false

  alias Chatroom.Repo
  alias Chatroom.Chats.Chat

  @spec get_user_chats(integer) :: [%Chat{}] | []
  def get_user_chats(user_id) do
    Repo.all(from ch in Chat, where: ch.user_id == ^user_id)
  end

  @spec get_chat_by_id!(integer()) :: %Chat{} | Ecto.NoResultsError
  def get_chat_by_id!(id) do
    Repo.get!(Chat, id)
  end

  @spec get_chat_by!(map()) :: %Chat{} | Ecto.NoResultsError
  def get_chat_by!(opts) do
    Repo.get_by!(Chat, opts)
  end

  @spec create_chat(map()):: %Chat{} | Ecto.Error
  def create_chat(attrs) do
      %Chat{}
      |> Chat.changeset(attrs)
      |> Repo.insert()
  end

end
