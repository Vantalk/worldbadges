defmodule Worldbadges.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :author_id, :integer

      # Relations
      # TODO handle on persona delete
      add :article_id, references(:articles, on_delete: :delete_all)
      add :page_id, references(:pages, on_delete: :delete_all)
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

  end
end
