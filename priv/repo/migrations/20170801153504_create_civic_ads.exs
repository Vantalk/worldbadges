defmodule Worldbadges.Repo.Migrations.CreateCivicAds do
  use Ecto.Migration

  def change do
    create table(:civic_ads) do
      add :name, :string
      add :image, :string
      add :url, :string, default: "#"
      add :status, :string, default: "pending"

      # Relations
      add :persona_id, references(:personas, on_delete: :delete_all)

      timestamps()
    end

  end
end
