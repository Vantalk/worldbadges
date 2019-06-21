defmodule Worldbadges.Groups.Page do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Groups.Page


  schema "pages" do
    field :free_access, :boolean, default: false
    field :name, :string
    field :image, :string
    field :public_view, :boolean, default: false
    field :roles, :map
    field :persona_id, :integer
    # field :badge_id, :integer
    field :parent_page_id, :integer
    field :general_page_id, :integer

    # Relations
    belongs_to :badge, Worldbadges.Features.Badge
    # belongs_to :persona, Worldbadges.Accounts.Persona

    has_one  :pending_persona, Worldbadges.Groups.PendingPersona

    many_to_many :personas, Worldbadges.Accounts.Persona, join_through: Worldbadges.Joins.PagePersona

    timestamps()
  end

  @doc false
  def changeset(%Page{} = page, attrs) do
    page
    |> cast(attrs, [:image, :name, :free_access, :public_view, :roles, :badge_id, :parent_page_id, :general_page_id, :persona_id])
    |> validate_required([:image, :name, :free_access, :public_view, :roles, :parent_page_id, :general_page_id, :persona_id])
    |> unique_constraint(:name)
    |> unique_constraint(:image)
  end
end
