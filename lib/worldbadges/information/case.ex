defmodule Worldbadges.Information.Case do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Information.Case


  schema "cases" do
    field :type,       :string, null: false
    field :persona_id, :integer
    field :object_id,  :integer
    field :details,    :string

    timestamps()
  end

  @doc false
  def changeset(%Case{} = notification, attrs) do
    notification
    |> cast(attrs, [:type, :persona_id, :object_id, :details])
    |> validate_required([:type])
  end
end
