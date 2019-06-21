defmodule Worldbadges.Groups.Chat do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.Chat


  schema "chats" do
    field :name, :string

    # Relations
    many_to_many :personas, Worldbadges.Accounts.Persona, join_through: Worldbadges.Joins.ChatPersona

    timestamps()
  end

  @doc false
  def changeset(%Chat{} = chat, attrs) do
    chat
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
