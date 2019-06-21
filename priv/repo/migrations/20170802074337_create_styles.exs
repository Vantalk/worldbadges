defmodule Worldbadges.Repo.Migrations.CreateStyles do
  use Ecto.Migration

  def change do
    create table(:styles) do
      add :settings, :map

      # Relations
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:styles, [:persona_id])
  end
end
