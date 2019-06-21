defmodule Worldbadges.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :name, :string

      timestamps()
    end

  end
end
