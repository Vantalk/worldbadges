defmodule Worldbadges.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :recipient_id, :integer
      add :group_chat, :boolean, default: false, null: false

      # Relations
      # TODO handle on persona delete
      add :persona_id, references(:personas, on_delete: :nothing)

      add :expiry_at, :utc_datetime, null: false
      timestamps()
    end

  end
end
