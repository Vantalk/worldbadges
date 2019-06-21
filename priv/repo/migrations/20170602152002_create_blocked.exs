defmodule Worldbadges.Repo.Migrations.CreateBlocked do
  use Ecto.Migration

  def change do
    create table(:blocked) do
      add :ids, {:array, :integer}

      # Relations
      add :persona_id, references(:personas, on_delete: :delete_all)

      timestamps()
    end

    create index(:blocked, [:persona_id])
  end
end
