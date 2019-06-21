defmodule Worldbadges.Repo.Migrations.CreateWorldbadges do
  use Ecto.Migration

  def change do
    create table(:badges) do
      # Details
      add :name, :string
      add :image, :string
      # add :description, :string
      # add :requirements, :text

      # Relations
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end
  end
end
