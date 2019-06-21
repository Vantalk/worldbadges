defmodule Worldbadges.Joins.AdBadge do
  use Ecto.Schema

  @primary_key false
  schema "ads_badges" do
    belongs_to :ad, Page
    belongs_to :badge, Persona
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:ad_id, :badge_id,])
    |> Ecto.Changeset.validate_required([:ad_id, :badge_id])
    # Maybe do some counter caching here!
  end
end
