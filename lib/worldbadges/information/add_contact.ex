defmodule Worldbadges.Information.AddContact do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Information.AddContact

  @primary_key false
  schema "add_contacts" do
    field :requested, :integer
    field :requester, :integer
    field :inserted_at, Timex.Ecto.DateTime, null: false
  end

  @doc false
  def changeset(%AddContact{} = add_contact, attrs) do
    add_contact
    |> cast(attrs, [:requester, :requested, :inserted_at])
    |> validate_required([:requester, :requested, :inserted_at])
    |> unique_constraint(:uniq_row_index, name: :add_contact)
  end
end
