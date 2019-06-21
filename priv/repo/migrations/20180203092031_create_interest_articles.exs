defmodule Worldbadges.Repo.Migrations.CreateInterestArticles do
  use Ecto.Migration

  def change do
    create table(:interest_articles, primary_key: false) do
      add :expiry_at, :date

      # Relations
      add :article_id, references(:articles, on_delete: :delete_all)
      add :persona_id, references(:personas, on_delete: :nothing)
    end

    create index(:interest_articles, [:article_id])
    create index(:interest_articles, [:persona_id])
    create index(:interest_articles, [:expiry_at])
  end
end
