defmodule Worldbadges.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :image, :string
      add :name, :string
      add :free_access, :boolean, default: false, null: false
      add :public_view, :boolean, default: false, null: false
      add :roles, :map
      add :persona_id, :integer
      # add :badge_id, :integer
      add :parent_page_id, :integer
      add :general_page_id, :integer

      # Relations
      # TODO: handle on badge/persona deletion
      add :badge_id, references(:badges, on_delete: :nothing)
      # add :persona_id, references(:personas, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:pages, [:name])
  end
end
