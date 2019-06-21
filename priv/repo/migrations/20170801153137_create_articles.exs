defmodule Worldbadges.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :content, :text
      add :data, :jsonb
      add :visibility, {:array, :integer}
      add :recognitions, :integer, default: 0, null: false

      # Relations
      # TODO: handle on persona delete
      add :page_id, references(:pages, on_delete: :delete_all)
      add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

  end
end
