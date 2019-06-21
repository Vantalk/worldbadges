defmodule Worldbadges.Groups.BadgeGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.BadgeGroup


  schema "badge_groups" do
    field :ids, {:array, :integer}
    field :name

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%BadgeGroup{} = badge_group, attrs) do
    badge_group
    |> cast(attrs, [:ids, :name, :persona_id])
    |> validate_required([:ids, :name])
    |> validate_length(:name, max: 20)
  end
end
