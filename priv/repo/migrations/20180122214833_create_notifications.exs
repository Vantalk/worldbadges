defmodule Worldbadges.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :action, :integer
      add :link, :string

      # Relations
      add :page_id,    :integer
      add :persona_id, :integer #subject of notification, not author

      timestamps()
    end

  end
end
