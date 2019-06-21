defmodule Worldbadges.Repo.Migrations.CreateDeleteTasks do
  use Ecto.Migration

  def change do
    create table(:delete_tasks) do
      add :type, :string, null: false
      add :obj_id, :bigint, null: false
      add :status, :integer
      add :error_id, :integer #:bigint

      timestamps()
    end

  end
end
