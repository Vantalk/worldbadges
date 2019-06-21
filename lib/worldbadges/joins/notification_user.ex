defmodule Worldbadges.Joins.NotificationPersona do
  use Ecto.Schema
  import Ecto.Changeset
  # alias Worldbadges.Joins.NotificationPersona

  @primary_key false
  schema "notifications_personas" do
    belongs_to :notification, Notification
    belongs_to :persona, Persona
  end

  @doc false
  def changeset(notification_persona, attrs) do
    notification_persona
    |> cast(attrs, [:notification_id, :persona_id])
    |> validate_required([:notification_id, :persona_id])
  end
end
