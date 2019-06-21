defmodule Worldbadges.Groups.Blocked do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.Blocked


  schema "blocked" do
    field :ids, {:array, :integer}

    belongs_to   :persona,   Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%Blocked{} = blocked, attrs) do
    blocked
    |> cast(attrs, [:ids, :persona_id])
    |> validate_required([:ids, :persona_id])
  end
end
