defmodule Worldbadges.Repo.Migrations.CreateTotalEvents do
  use Ecto.Migration

  def change do
    create table(:total_events) do
      add :total, :integer
      add :persona_id, references(:personas)

      timestamps()
    end

    create index(:total_events, [:persona_id])
  end
end
