defmodule Worldbadges.Posting.Ad do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Posting.Ad


  schema "ads" do
    field :name, :string
    field :image, :string
    field :url, :string
    field :targets, {:array, :integer}
    field :status, :string, default: "Pending: Your ad was queued for approval"

    belongs_to   :persona,   Worldbadges.Accounts.Persona
    many_to_many :badges, Worldbadges.Features.Badge, join_through: Worldbadges.Joins.AdBadge

    timestamps()
  end

  @doc false
  def changeset(%Ad{} = ad, attrs) do
    ad
    |> cast(attrs, [:name, :image, :url, :targets, :status, :persona_id])
    |> validate_required([:name, :image, :targets, :persona_id])
  end
end
