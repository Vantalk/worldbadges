defmodule Worldbadges.Repo.Migrations.CreatePendingArticles do
  use Ecto.Migration

  def change do
    create table(:pending_articles) do
      add :content, :text
      add :image, :string
      add :page_id, references(:pages, on_delete: :nothing)
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

    create index(:pending_articles, [:page_id])
    create index(:pending_articles, [:persona_id])
  end
end
