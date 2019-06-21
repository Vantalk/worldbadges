defmodule Worldbadges.Repo.Migrations.CreatePrivacy do
  use Ecto.Migration

  def change do
    create table(:privacy) do
      # Details
      add :settings,  :map

      # Relations
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

  end
end
