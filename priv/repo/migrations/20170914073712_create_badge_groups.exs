defmodule Worldbadges.Repo.Migrations.CreateBadgeGroups do
  use Ecto.Migration

  def change do
    create table(:badge_groups) do
      add :ids, {:array, :integer}
      add :name, :string

      # Relations
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

    create index(:badge_groups, [:name])
    create index(:badge_groups, [:persona_id])
  end
end
