defmodule Worldbadges.Features.Recognition do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Features.Recognition


  schema "recognitions" do
    # field :is_article, :boolean, default: false
    field :article_id, :integer
    field :receiver_id, :integer
    field :persona_id, :integer

    belongs_to :page, Worldbadges.Posting.Page

    timestamps()
  end

  @doc false
  def changeset(%Recognition{} = recognition, attrs) do
    recognition
    |> cast(attrs, [:page_id, :persona_id, :receiver_id, :article_id])#, :is_article])
    |> validate_required([:page_id, :persona_id, :receiver_id, :article_id])#, :is_article])
  end
end
