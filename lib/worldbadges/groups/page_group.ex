defmodule Worldbadges.Groups.PageGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.PageGroup


  schema "page_groups" do
    field :ids, {:array, :integer}
    field :name

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%PageGroup{} = page_group, attrs) do
    page_group
    |> cast(attrs, [:ids, :name, :persona_id])
    |> validate_required([:ids, :name])
    |> validate_length(:name, max: 20)
  end
end
