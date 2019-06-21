defmodule Worldbadges.Repo.Migrations.CreatePageGroups do
  use Ecto.Migration

  def change do
    create table(:page_groups) do
      add :ids, {:array, :integer}
      add :name, :string

      # Relations
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

    create index(:page_groups, [:name])
    create index(:page_groups, [:persona_id])
  end
end
