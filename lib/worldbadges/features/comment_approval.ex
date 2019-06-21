defmodule Worldbadges.Features.CommentApproval do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Features.CommentApproval

  @primary_key false
  schema "comment_approvals" do
    field :results, {:array, :integer}
    field :voters, :map

    # Relations
    belongs_to :comment, Worldbadges.Posting.Comment
    belongs_to :page, Worldbadges.Posting.Page
    belongs_to :persona, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc false
  def changeset(%CommentApproval{} = comment_approval, attrs) do
    comment_approval
    |> cast(attrs, [:voters, :results, :comment_id, :page_id, :persona_id])
    |> validate_required([:voters, :results, :comment_id, :persona_id])
  end
end
