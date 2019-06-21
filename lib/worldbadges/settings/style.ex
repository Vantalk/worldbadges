defmodule Worldbadges.Settings.Style do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Settings.Style


  schema "styles" do
    field :settings, :map

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%Style{} = style, attrs) do
    style
    |> cast(attrs, [:settings, :persona_id])
    |> validate_required([:settings, :persona_id])
    |> unique_constraint(:persona_id)
  end
end
