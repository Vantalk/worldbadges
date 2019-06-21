defmodule Worldbadges.Repo.Migrations.CreateArticleExpiry do
  use Ecto.Migration

  def change do
    create table(:article_expiry) do
      add :date, :utc_datetime
      add :article_id, references(:articles, on_delete: :nothing)

      timestamps()
    end

    create index(:article_expiry, [:date])
  end
end
