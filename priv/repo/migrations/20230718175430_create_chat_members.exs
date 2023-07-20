defmodule Chatroom.Repo.Migrations.CreateChatMembers do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:chat_members) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :chat_id, references(:chats, on_delete: :delete_all), null: false
    end

    create unique_index(:chat_members, [:user_id, :chat_id])
  end
end
