defmodule Worldbadges.Repo.Migrations.CreateConsents do
  use Ecto.Migration

  def change do
    create table(:consents) do
      add :consented, :boolean, default: false, null: false
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

    create index(:consents, [:persona_id])
  end
end
