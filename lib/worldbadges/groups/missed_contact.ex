defmodule Worldbadges.Groups.MissedContact do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.MissedContact


  schema "missed_contacts" do
    field :ids, {:array, :integer}

    # Relations
    belongs_to :persona, Worldbadges.Groups.Persona

    timestamps()
  end

  @doc false
  def changeset(%MissedContact{} = missed_contact, attrs) do
    missed_contact
    |> cast(attrs, [:ids, :persona_id])
    |> validate_required([:ids, :persona_id])
  end
end
