defmodule Worldbadges.Groups.PendingPersona do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.PendingPersona


  schema "pending_personas" do
    field :invites, {:array, :integer}, default: []
    field :requests, {:array, :integer}, default: []
    field :page_id, :id

    timestamps()
  end

  @doc false
  def changeset(%PendingPersona{} = pending_persona, attrs) do
    pending_persona
    |> cast(attrs, [:invites, :requests, :page_id])
    |> validate_required([:invites, :requests, :page_id])
  end
end
