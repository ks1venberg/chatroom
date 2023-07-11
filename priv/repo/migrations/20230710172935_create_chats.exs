defmodule Chatroom.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:chats) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:chats, [:user_id, :name])
  end
end
