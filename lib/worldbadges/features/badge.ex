defmodule Worldbadges.Features.Badge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Features.Badge


  schema "badges" do
    # field :description, :string
    field :image, :string
    field :name, :string
    # field :requirements, :string

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona
    # has_many :personas, Worldbadges.Accounts.Persona
    has_one :page, Worldbadges.Groups.Page

    many_to_many :ads, Worldbadges.Posting.Ad, join_through: Worldbadges.Joins.AdBadge

    timestamps()
  end

  @doc false
  def changeset(%Badge{} = badge, attrs) do
    badge
    |> cast(attrs, [:image, :name, :persona_id])
    |> validate_required([:image, :name])
  end
end
