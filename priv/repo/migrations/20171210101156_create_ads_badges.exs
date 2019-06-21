defmodule Worldbadges.Repo.Migrations.Pagespersonas do
  use Ecto.Migration

  def change do
    create table(:ads_badges, primary_key: false) do
      add :ad_id, references(:ads)
      add :badge_id, references(:badges)
    end
  end
end
