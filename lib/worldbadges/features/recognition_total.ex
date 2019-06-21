defmodule Worldbadges.Features.RecognitionTotal do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Features.RecognitionTotal

  # @primary_key false
  schema "recognition_totals" do
    field :json, :map, null: false

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona
  end

  @doc false
  def changeset(%RecognitionTotal{} = recognition_total, attrs) do
    recognition_total
    |> cast(attrs, [:persona_id, :json])
    |> validate_required([:persona_id, :json])
  end
end
