defmodule Worldbadges.Posting.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Posting.Comment


  schema "comments" do
    field :content, :string
    field :author_id, :integer

    # Relations
    belongs_to :article, Worldbadges.Posting.Article
    belongs_to :page, Worldbadges.Posting.Page
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:content, :article_id, :author_id, :page_id, :persona_id])
    |> validate_required([:content, :article_id, :author_id, :persona_id])
  end
end
