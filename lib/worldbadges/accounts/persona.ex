defmodule Worldbadges.Accounts.Persona do
  use Ecto.Schema
  import Ecto.Changeset

  alias Worldbadges.Repo

  schema "personas" do
    # Personal details
    field :delete,        :boolean, default: false, null: false
    field :image,         :string, default: "avatar", null: false
    field :name,          :string, null: false

    # Relations
    belongs_to :user,            Worldbadges.Accounts.User, type: :binary_id

    has_many :ads,               Worldbadges.Posting.Ad
    has_many :articles,          Worldbadges.Posting.Article
    has_many :badges,            Worldbadges.Features.Badge
    has_many :badge_groups,      Worldbadges.Groups.BadgeGroup
    has_many :civic_ads,         Worldbadges.Posting.CivicAd
    has_many :interest_articles, Worldbadges.Information.InterestArticle
    # has_many :comments,     Worldbadges.Posting.Comment !NOT PRACTICAL TO USE
    # has_many :messages,     Worldbadges.Posting.Comment !NOT PRACTICAL TO USE
    # has_many :pages,        Worldbadges.Groups.Page
    has_many :page_groups,       Worldbadges.Groups.PageGroup
    has_many :persona_groups,    Worldbadges.Groups.PersonaGroup

    has_one  :badge_base,        Worldbadges.Information.BadgeBase
    has_one  :blocked,           Worldbadges.Groups.Blocked
    has_one  :contact,           Worldbadges.Groups.Contact
    has_one  :missed_contact,    Worldbadges.Groups.MissedContact
    has_one  :privacy,           Worldbadges.Settings.Privacy
    has_one  :style,             Worldbadges.Settings.Style

    many_to_many :chats, Worldbadges.Groups.Chat, join_through: Worldbadges.Joins.ChatPersona
    many_to_many :pages, Worldbadges.Groups.Page, join_through: Worldbadges.Joins.PagePersona

    field :left_at, Timex.Ecto.DateTime, null: false
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(left_at user_id)a
  @optional_fields ~w(delete image name)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:name, ~r/^[A-Za-z0-9._\s]+$/, [message: "Invalid format: Only letters, numbers and the symbols . and _ are accepted"])
  end
end
