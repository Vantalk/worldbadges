defmodule Worldbadges.Information.BadgeBase do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Information.BadgeBase


  schema "badge_bases" do
    field :image, :string

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%BadgeBase{} = badge_base, attrs) do
    badge_base
    |> cast(attrs, [:image, :persona_id])
    |> validate_required([:image, :persona_id])
  end
end
