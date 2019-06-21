defmodule Worldbadges.Groups.PersonaGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.PersonaGroup


  schema "persona_groups" do
    field :ids, {:array, :integer}
    field :name

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%PersonaGroup{} = persona_group, attrs) do
    persona_group
    |> cast(attrs, [:ids, :name, :persona_id])
    |> validate_required([:ids, :name])
    |> validate_length(:name, max: 20)
  end
end
