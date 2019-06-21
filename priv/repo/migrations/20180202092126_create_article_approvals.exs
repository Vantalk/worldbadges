defmodule Worldbadges.Repo.Migrations.CreateArticleApprovals do
  use Ecto.Migration

  def change do
    create table(:article_approvals, primary_key: false) do
      add :voters, :map
      add :results, {:array, :integer}

      # Relations
      add :article_id, references(:articles, on_delete: :delete_all)
      add :page_id, references(:pages, on_delete: :delete_all)
      add :persona_id, references(:personas, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:article_approvals, [:article_id])
    create unique_index(:article_approvals, [:persona_id])
  end
end
