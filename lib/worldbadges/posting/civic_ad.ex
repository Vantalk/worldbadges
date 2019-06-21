defmodule Worldbadges.Posting.CivicAd do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Posting.CivicAd


  schema "civic_ads" do
    field :name, :string
    field :image, :string
    field :url, :string
    field :status, :string, default: "pending"

    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%CivicAd{} = civic_ad, attrs) do
    civic_ad
    |> cast(attrs, [:name, :image, :url, :status, :persona_id])
    |> validate_required([:name, :image, :persona_id])
  end
end
