defmodule Chatroom.Chats.Chat do
  @moduledoc """
  Chats schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Chatroom.Accounts.User

  schema "chats" do
    field :name, :string
    belongs_to :user, User
    timestamps()
  end

  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_length(:name, min: 3, max: 20)
  end

end
