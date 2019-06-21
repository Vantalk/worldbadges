defmodule Worldbadges.Groups.Contact do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.Contact


  schema "contacts" do
    field :groups, :map, null: false

    # Relations
    belongs_to :persona, Worldbadges.Groups.Persona

    timestamps()
  end

  @doc false
  def changeset(%Contact{} = contact, attrs) do
    contact
    |> cast(attrs, [:groups, :persona_id])
    |> validate_required([:groups, :persona_id])
  end
end
