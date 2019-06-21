defmodule Worldbadges.Settings.Privacy do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Settings.Privacy


  schema "privacy" do
    field :settings, :map

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%Privacy{} = privacy, attrs) do
    privacy
    |> cast(attrs, [:settings, :persona_id])
    |> validate_required([:settings, :persona_id])
  end
end
