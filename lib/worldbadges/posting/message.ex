defmodule Worldbadges.Posting.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Posting.Message


  schema "messages" do
    field :content, :string
    field :recipient_id, :integer
    field :group_chat, :boolean, default: false

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona

    # TODO: expiry at according to log_time; add cron to clean
    field :expiry_at, Timex.Ecto.DateTime, null: false
    timestamps()
  end

  @doc false
  def changeset(%Message{} = message, attrs) do
    message
    |> cast(attrs, [:content, :expiry_at, :recipient_id, :group_chat, :persona_id])
    |> validate_required([:content, :expiry_at, :recipient_id, :persona_id])
  end
end
