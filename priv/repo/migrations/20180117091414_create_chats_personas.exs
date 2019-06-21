defmodule Worldbadges.Repo.Migrations.CreateChatsPersonas do
  use Ecto.Migration

  def change do
    create table(:chats_personas, primary_key: false) do
      add :chat_id, references(:chats)
      add :persona_id, references(:personas)
    end
  end
end
