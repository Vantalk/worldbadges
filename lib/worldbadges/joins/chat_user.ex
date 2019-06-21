defmodule Worldbadges.Joins.ChatPersona do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Joins.ChatPersona

  @primary_key false
  schema "chats_personas" do
    belongs_to :chat, Page
    belongs_to :persona, Persona
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:chat_id, :persona_id,])
    |> Ecto.Changeset.validate_required([:chat_id, :persona_id])
    # Maybe do some counter caching here!
  end
end
