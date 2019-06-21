defmodule Worldbadges.Repo.Migrations.CreateNotificationsPersonas do
  use Ecto.Migration

  def change do
    create table(:notifications_personas, primary_key: false) do
      add :notification_id, references(:notifications)
      add :persona_id, references(:personas)
    end
  end
end
