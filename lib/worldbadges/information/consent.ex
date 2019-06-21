defmodule Worldbadges.Information.Consent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Information.Consent


  schema "consents" do
    field :consented, :boolean, default: false
    field :persona_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Consent{} = consent, attrs) do
    consent
    |> cast(attrs, [:consented, :persona_id])
    |> validate_required([:persona_id])
  end
end
