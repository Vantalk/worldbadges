defmodule Worldbadges.Posting.PendingArticle do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Posting.PendingArticle


  schema "pending_articles" do
    field :content, :string
    field :image, :string
    field :page_id, :id
    field :persona_id, :id

    timestamps()
  end

  @doc false
  def changeset(%PendingArticle{} = pending_article, attrs) do
    pending_article
    |> cast(attrs, [:content, :image, :page_id, :persona_id])
    |> validate_required([:content, :page_id, :persona_id])
  end
end
