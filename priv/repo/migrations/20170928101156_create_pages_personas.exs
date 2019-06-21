defmodule Worldbadges.Repo.Migrations.PagesPersonas do
  use Ecto.Migration

  def change do
    create table(:pages_personas, primary_key: false) do
      add :page_id, references(:pages)
      add :persona_id, references(:personas)
    end
  end
end
