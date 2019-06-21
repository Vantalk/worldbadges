defmodule Worldbadges.Repo.Migrations.CreateBadgeBases do
  use Ecto.Migration

  def change do
    create table(:badge_bases) do
      add :image, :string
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

    create index(:badge_bases, [:persona_id])
  end
end
