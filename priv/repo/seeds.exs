# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Worldbadges.Repo.insert!(%Worldbadges.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Worldbadges.{
  Accounts.User,
  Accounts.Persona,
  Joins.PagePersona,
  Joins.AdBadge,
  Groups.Contact,
  Groups.Page,
  Groups.BadgeGroup,
  Groups.PageGroup,
  Information.BadgeBase,
  Features.Badge,
  Features.CommentApproval,
  Posting.Article,
  Posting.Ad,
  Posting.CivicAd,
  Posting.Comment,
  Settings.Privacy,
  Settings.Style,
  Repo
}

%Badge{} |> Badge.changeset(%{name: "Art & Culture", image: "Art & Culture"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "History", image: "History"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "Science & Technology", image: "Science & Technology"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "Health", image: "Health"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "Business & Economy", image: "Business & Economy"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "Beauty & Fashion", image: "Beauty & Fashion"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "Food", image: "Food"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "Sports & Relaxation", image: "Sports & Relaxation"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "Social Life", image: "Social Life"}) |> Repo.insert!
%Badge{} |> Badge.changeset(%{name: "Nature", image: "Nature"}) |> Repo.insert!

%Page{} |> Page.changeset(%{name: "Art & Culture", image: "Art & Culture", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 1, parent_page_id: 1, general_page_id: 1 }) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "History", image: "History", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 2, parent_page_id: 2, general_page_id: 2}) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "Science & Technology", image: "Science & Technology", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 3, parent_page_id: 3, general_page_id: 3}) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "Health", image: "Health", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 4, parent_page_id: 4, general_page_id: 4}) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "Business & Economy", image: "Business & Economy", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 5, parent_page_id: 5, general_page_id: 5}) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "Beauty & Fashion", image: "Beauty & Fashion", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 6, parent_page_id: 6, general_page_id: 6}) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "Food", image: "Food", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 7, parent_page_id: 7, general_page_id: 7}) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "Sports & Relaxation", image: "Sports & Relaxation", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 8, parent_page_id: 8, general_page_id: 8}) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "Social Life", image: "Social Life", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 9, parent_page_id: 9, general_page_id: 9}) |> Repo.insert!
%Page{} |> Page.changeset(%{name: "Nature", image: "Nature", free_access: true, public_view: true, roles: %{"admins" => [], "mods" => []}, persona_id: 0, badge_id: 10, parent_page_id: 10, general_page_id: 10}) |> Repo.insert!

# %Article{} |> Article.changeset(%{content: "This is a main interest page. Posting to this page is moderated."}) |> Repo.insert!
# %Article{} |> Article.changeset(%{content: "This is a main interest page. Posting to this page is moderated."}) |> Repo.insert!

%BadgeGroup{} |> BadgeGroup.changeset(%{ids: Enum.to_list(1..10), name: "General badges"}) |> Repo.insert!
%PageGroup{} |> PageGroup.changeset(%{ids: Enum.to_list(1..10), name: "General pages"}) |> Repo.insert!

# %Ad{} |> Ad.changeset(%{name: "ad", image: "ad.jpg", targets: [1], persona_id: 1}) |> Repo.insert!
# %Ad{} |> Ad.changeset(%{name: "ad2", image: "ad2.jpg", targets: [1], persona_id: 1}) |> Repo.insert!
