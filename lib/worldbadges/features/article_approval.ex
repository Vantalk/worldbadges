defmodule Worldbadges.Features.ArticleApproval do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Features.ArticleApproval

  @primary_key false
  schema "article_approvals" do
    field :results, {:array, :integer}
    field :voters, :map

    # Relations
    belongs_to :article, Worldbadges.Posting.Article
    belongs_to :page, Worldbadges.Posting.Page
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%ArticleApproval{} = article_approval, attrs) do
    article_approval
    |> cast(attrs, [:voters, :results, :article_id, :page_id, :persona_id])
    |> validate_required([:voters, :results, :article_id, :persona_id])
  end
end
