defmodule Worldbadges.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :key,           :string, null: false
      add :pid,           :bigint
      add :mid,           :string, null: false

      add :delete,        :boolean, default: false, null: false

      # Password related
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:users, [:key])
    create unique_index(:users, [:mid])
  end
end
