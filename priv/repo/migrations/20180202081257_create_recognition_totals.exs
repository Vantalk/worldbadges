defmodule Worldbadges.Repo.Migrations.CreateRecognitionTotals do
  use Ecto.Migration

  def change do
    create table(:recognition_totals) do
      add :json,    :jsonb, null: false

      # Relations
      add :persona_id, references(:personas, on_delete: :delete_all)
    end

    create unique_index(:recognition_totals, [:persona_id])
  end
end
