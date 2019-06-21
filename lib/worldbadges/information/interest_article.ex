defmodule Worldbadges.Information.InterestArticle do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Information.InterestArticle

  @primary_key false
  schema "interest_articles" do
    field :expiry_at, :date

    # Relations
    belongs_to :persona, Worldbadges.Accounts.Persona
    belongs_to :article, Worldbadges.Posting.Article
  end

  @doc false
  def changeset(%InterestArticle{} = interest_article, attrs) do
    interest_article
    |> cast(attrs, [:expiry_at, :article_id, :persona_id])
    |> validate_required([:expiry_at, :article_id, :persona_id])
  end
end
