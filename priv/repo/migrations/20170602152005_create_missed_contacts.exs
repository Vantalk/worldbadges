defmodule Worldbadges.Repo.Migrations.CreateMissedContacts do
  use Ecto.Migration

  def change do
    create table(:missed_contacts) do
      add :ids, {:array, :integer}

      # Relations
      add :persona_id, references(:personas, on_delete: :delete_all)

      timestamps()
    end

    create index(:missed_contacts, [:persona_id])
  end
end
