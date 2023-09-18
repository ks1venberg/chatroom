defmodule Chatroom.Chats do
  @moduledoc """
    DB logic for Chats context
  """
  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Chatroom.Accounts
  alias Chatroom.Repo
  alias Chatroom.Chats.Chat

  @spec get_all() :: [%Chat{}] | []
  def get_all() do
    Repo.all(from ch in Chat)
  end

  @spec get_chat_by_id!(integer()) :: %Chat{} | Ecto.NoResultsError
  def get_chat_by_id!(id) do
    Repo.get!(Chat, id)
  end

  @spec create_chat(map()):: {:ok, %Chat{}} | {:error, Ecto.Changeset.t()}
  def create_chat(attrs) do
    user = Accounts.get_user!(attrs.user_id)

      %Chat{}
      |> Chat.changeset(attrs)
      |> put_assoc(:members, [user])
      |> Repo.insert()
  end

end
