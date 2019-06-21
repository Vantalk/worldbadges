defmodule Worldbadges.Repo.Migrations.CreatePersonas do
  use Ecto.Migration

  def change do
    create table(:personas) do
      # Personal details
      add :name,    :string, null: false
      add :image,   :string, default: "avatar"

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :delete,  :boolean, default: false, null: false

      # Timestamps
      add :left_at, :utc_datetime, null: false
      # add :new_left_at, :utc_datetime, null: false
      timestamps()
    end
  end
end
