defmodule Worldbadges.Repo.Migrations.CreateRecognitions do
  use Ecto.Migration

  def change do
    create table(:recognitions) do
      add :persona_id, :integer
      add :receiver_id, :integer
      add :article_id, :integer
      # add :is_article, :boolean, default: false, null: false

      add :page_id, references(:pages, on_delete: :delete_all)

      timestamps()
    end
  end
end
