defmodule Worldbadges.Repo.Migrations.CreateAds do
  use Ecto.Migration

  def change do
    create table(:ads) do
      add :name, :string
      add :image, :string
      add :url, :string, default: "#"
      add :targets, {:array, :integer}
      add :status, :string, default: "Pending: Your ad was queued for approval"

      # Relations
      add :persona_id, references(:personas, on_delete: :delete_all)

      timestamps()
    end

  end
end
