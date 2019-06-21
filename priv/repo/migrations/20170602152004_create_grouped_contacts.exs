defmodule Worldbadges.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :groups, :jsonb, null: false

      # Relations
      add :persona_id, references(:personas, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:contacts, [:persona_id])
  end
end
