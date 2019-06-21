defmodule Worldbadges.Repo.Migrations.CreatePendingPersonas do
  use Ecto.Migration

  def change do
    create table(:pending_personas) do
      add :invites, {:array, :integer}
      add :requests, {:array, :integer}

      add :page_id, references(:pages, on_delete: :nothing)

      timestamps()
    end

    create index(:pending_personas, [:page_id])
  end
end
