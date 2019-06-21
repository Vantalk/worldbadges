defmodule Worldbadges.Information.Notification do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Information.Notification


  schema "notifications" do
    field :action, :integer
    field :link, :string

    field :page_id, :integer
    field :persona_id, :integer

    timestamps()
  end

  @doc false
  def changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:action, :link, :page_id, :persona_id])
    |> validate_required([:action, :link])
  end
end
