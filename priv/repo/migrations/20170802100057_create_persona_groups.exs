defmodule Worldbadges.Repo.Migrations.CreatePersonaGroups do
  use Ecto.Migration

  def change do
    create table(:persona_groups) do
      add :ids, {:array, :integer}
      add :name, :string

      # Relations
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

    create index(:persona_groups, [:name])
    create index(:persona_groups, [:persona_id])
  end
end
