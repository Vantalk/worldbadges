defmodule Worldbadges.Posting.Article do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Posting.Article


  schema "articles" do
    field :content, :string
    field :data, :map
    field :visibility, {:array, :integer}
    field :recognitions, :integer, default: 0, null: false

    # Relations
    belongs_to :page, Worldbadges.Groups.Page
    belongs_to :persona, Worldbadges.Accounts.Persona

    has_one    :badge, through: [:page, :badge]
    has_many   :comments, Worldbadges.Posting.Comment

    timestamps()
  end

  @doc false
  def changeset(%Article{} = article, attrs) do
    article
    |> cast(attrs, [:content, :data, :visibility, :page_id, :persona_id, :recognitions])
    |> validate_required([:persona_id])
  end
end
