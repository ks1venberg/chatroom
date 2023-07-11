defmodule Chatroom.Chats do
  @moduledoc """
    DB logic for Chats
  """
  import Ecto.Query, warn: false

  alias Chatroom.Repo
  alias Chatroom.Chats.Chat

  @spec get_user_chats(integer) :: [%Chat{}] | []
  def get_user_chats(user_id) when is_integer(user_id) do
    Repo.all(from ch in Chat, where: ch.user_id == ^user_id)
  end

  @spec get_chat!(integer()) :: %Chat{} | Ecto.NoResultsError
  def get_chat!(id) do
    Repo.get!(Chat, id)
  end

  @spec create_chat(%{}) :: {:ok, %Chat{}} | {:error, Ecto.Changeset.t}
  def create_chat(attrs) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

end
