defmodule Worldbadges.Joins.PagePersona do
  use Ecto.Schema

  @primary_key false
  schema "pages_personas" do
    belongs_to :page, Page
    belongs_to :persona, Persona
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:page_id, :persona_id,])
    |> Ecto.Changeset.validate_required([:page_id, :persona_id])
    # Maybe do some counter caching here!
  end
end
