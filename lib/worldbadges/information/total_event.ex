defmodule Worldbadges.Information.TotalEvent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Information.TotalEvent


  schema "total_events" do
    field :total, :integer
    field :persona_id, :id

    timestamps()
  end

  @doc false
  def changeset(%TotalEvent{} = total_event, attrs) do
    total_event
    |> cast(attrs, [:total, :persona_id])
    |> validate_required([:persona_id])
  end
end
