defmodule Worldbadges.Repo.Migrations.CreateCommentApprovals do
  use Ecto.Migration

  def change do
    create table(:comment_approvals, primary_key: false) do
      add :voters, :map
      add :results, {:array, :integer}

      # Relations
      add :comment_id, references(:comments, on_delete: :delete_all)
      add :page_id, references(:pages, on_delete: :delete_all)
      add :persona_id, references(:personas, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:comment_approvals, [:comment_id])
    create unique_index(:comment_approvals, [:persona_id])
  end
end
