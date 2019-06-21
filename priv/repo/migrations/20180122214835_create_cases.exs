defmodule Worldbadges.Repo.Migrations.CreateCases do
  use Ecto.Migration

  def change do
    create table(:cases) do
      add :type,       :string, null: false
      add :persona_id, :integer
      add :object_id,  :integer
      add :details,    :string

      timestamps()
    end

    create index(:cases, [:type])
  end
end
