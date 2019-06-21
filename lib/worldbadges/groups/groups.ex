defmodule Worldbadges.Groups do
  @moduledoc """
  The Groups context.
  """

  import WorldbadgesWeb.Shared, only: [contact_ids: 1]
  import Ecto.Query, warn: false
  alias Worldbadges.Repo

  alias Worldbadges.Groups.Page

  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages do
    Repo.all(Page)
  end

  @doc """
  TODO
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def pages_for(persona_id) do
    subdpages_group(persona_id).ids
    |> get_pages()
  end

  def pages_for(persona_id, limit, offset) do
    page_ids = subdpages_group(persona_id).ids
    page_ids = page_ids |> Enum.slice(offset,limit)
    unless page_ids == [], do: get_pages(page_ids)
  end

  # TODO: documentation
  def pages_with_exception_for(persona_id, exception_ids, limit, offset) do
    page_ids = subdpages_group(persona_id).ids -- exception_ids
    page_ids = page_ids |> Enum.slice(offset,limit)
    get_pages(page_ids)
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(id), do: Repo.get!(Page, id)

  @doc """
  TODO
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_persona_page!(name, persona_id), do: Repo.get_by!(Page, name: name, persona_id: persona_id)

  # TODO documentation
  def page_member?(page_id, persona_id) do
    page_id in subdpages_group(persona_id).ids
  end

  @doc """
  TODO
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  SELECT *
  FROM pages AS p
  WHERE p.name = 'Art'
  AND
  p.id = ANY((SELECT ids FROM page_groups WHERE persona_id = 3 AND name = 'SubdPages')::int[])

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subd_page(name, persona_id) do
    from(p in Worldbadges.Groups.Page,
      where: p.name == ^name and
      p.id == fragment("any((SELECT ids FROM page_groups WHERE persona_id = ? AND name = 'SubdPages')::int[])", ^persona_id)
    ) |> Repo.one()
  end

  @doc """
  TODO
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pages(page_ids) do
    from(p in Page, where: p.id in ^page_ids, order_by: fragment("lower(?)", p.name))
    |> Repo.all()
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page_by_name!('animal_lovers')
      %Page{}

      iex> get_page_by_name!('bad_name')
      ** (Ecto.NoResultsError)

  """
  def get_page_by_name!(name), do: Repo.get_by!(Page, name: name)

  # TODO documentation; add limit
  def search_pages(general_page_ids, input) when general_page_ids == [] do
    from(p in Page, where: ilike(p.name, ^input)) |> Repo.all()
  end
  def search_pages(general_page_ids, input) do
    from(p in Page, where: ilike(p.name, ^input) and p.general_page_id in ^general_page_ids) |> Repo.all()
  end

  # def search_pages(general_page_ids, input, persona_id) when general_page_ids == [] do
  #   from(
  #     p in Page, where: ilike(p.name, ^input),
  #     join: pg in Worldbadges.Groups.PageGroup, on: pg.persona_id == ^persona_id and
  #     pg.name == "SubdPages" and not p.id in pg.ids
  #   ) |> Repo.all()
  # end
  #
  # # TODO documentation; add limit
  # def search_pages(general_page_ids, input, persona_id) do
  #   from(
  #     p in Page, where: ilike(p.name, ^input) and p.general_page_id in ^general_page_ids,
  #     join: pg in Worldbadges.Groups.PageGroup, on: pg.persona_id == ^persona_id and
  #     pg.name == "SubdPages" and not p.id in pg.ids
  #   ) |> Repo.all()
  # end

  @doc """
  TODO
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page_by_name!('animal_lovers')
      %Page{}

      iex> get_page_by_name!('bad_name')
      ** (Ecto.NoResultsError)

  """
  def page_ids_by_badges(badge_ids) do
    from(p in Page, select: p.id, where: p.badge_id in ^badge_ids) |> Repo.all()
  end

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(%{field: value})
      {:ok, %Page{}}

      iex> create_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  TODO
  Deletes a Page.

  ## Examples

      iex> delete_page(page)
      {:ok, %Page{}}

      iex> delete_page(page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(page_name, persona_id) do
    from(p in Page, where: p.name == ^page_name and p.persona_id == ^persona_id)
    |> Repo.delete_all
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(page)
      %Ecto.Changeset{source: %Page{}}

  """
  def change_page(%Page{} = page) do
    Page.changeset(page, %{})
  end

  alias Worldbadges.Groups.PersonaGroup

  @doc """
  Returns the list of persona_groups.

  ## Examples

      iex> list_persona_groups()
      [%PersonaGroup{}, ...]

  """
  def list_persona_groups do
    Repo.all(PersonaGroup)
  end

  @doc """
  Gets a single persona_group.

  Raises `Ecto.NoResultsError` if the Persona group does not exist.

  ## Examples

      iex> get_persona_group!(123)
      %PersonaGroup{}

      iex> get_persona_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_persona_group!(id), do: Repo.get!(PersonaGroup, id)

  @doc """
  TODO
  Gets a single persona_group.

  Raises `Ecto.NoResultsError` if the Persona group does not exist.

  ## Examples

      iex> get_persona_group!(123)
      %PersonaGroup{}

      iex> get_persona_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_persona_group!(name, persona_id), do: Repo.get_by!(PersonaGroup, name: name, persona_id: persona_id)

  @doc """
  TODO
  Gets a single persona_group.

  Raises `Ecto.NoResultsError` if the Persona group does not exist.

  ## Examples

      iex> get_persona_group!(123)
      %PersonaGroup{}

      iex> get_persona_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_persona_group(persona_id, name), do: Repo.get_by(PersonaGroup, persona_id: persona_id, name: name)

  # TODO documentation
  def get_persona_groups(persona_id) do
    from(p in PersonaGroup, where: p.persona_id == ^persona_id)
    |> Repo.all()
  end

  @doc """
  Gets "MyPersonas" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def mypersonas_group(persona_id) do
    Repo.get_by!(PersonaGroup, name: "MyPersonas", persona_id: persona_id)
  end

  @doc """
  Creates a persona_group.

  ## Examples

      iex> create_persona_group(%{field: value})
      {:ok, %PersonaGroup{}}

      iex> create_persona_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_persona_group(attrs \\ %{}) do
    %PersonaGroup{}
    |> PersonaGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a persona_group.

  ## Examples

      iex> update_persona_group(persona_group, %{field: new_value})
      {:ok, %PersonaGroup{}}

      iex> update_persona_group(persona_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_persona_group(%PersonaGroup{} = persona_group, attrs) do
    persona_group
    |> PersonaGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  TODO
  Deletes a PersonaGroup.

  ## Examples

      iex> delete_persona_group(persona_group)
      {:ok, %PersonaGroup{}}

      iex> delete_persona_group(persona_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_persona_group(persona_group_name, persona_id) do
    from(u in PageGroup, where: u.id == ^persona_group_name and u.persona_id == ^persona_id)
    |> Repo.delete_all
  end


  @doc """
  Returns an `%Ecto.Changeset{}` for tracking persona_group changes.

  ## Examples

      iex> change_persona_group(persona_group)
      %Ecto.Changeset{source: %PersonaGroup{}}

  """
  def change_persona_group(%PersonaGroup{} = persona_group) do
    PersonaGroup.changeset(persona_group, %{})
  end

  alias Worldbadges.Groups.PageGroup

  @doc """
  Returns the list of page_groups.

  ## Examples

      iex> list_page_groups()
      [%PageGroup{}, ...]

  """
  def list_page_groups do
    Repo.all(PageGroup)
  end

  @doc """
  Gets a single page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.

  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page_group!(id), do: Repo.get!(PageGroup, id)

  @doc """
  TODO
  Gets a single page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.

  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page_group!(name, persona_id), do: Repo.get_by!(PageGroup, name: name, persona_id: persona_id)

  @doc """
  TODO
  Gets a single page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.

  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page_group(persona_id, name), do: Repo.get_by(PageGroup, persona_id: persona_id, name: name)

  @doc """
  Gets "MyPages" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def generalpages_group(), do: Repo.get_by!(PageGroup, name: "General pages")

  @doc """
  Gets "MyPages" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def general_pages() do
    page_ids = generalpages_group().ids
    get_pages(page_ids)
  end

  @doc """
  Gets "MyPages" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def mypages_group(persona_id) do
    Repo.get_by!(PageGroup, name: "MyPages", persona_id: persona_id)
  end

  @doc """
  Gets "MyPages" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def my_pages(persona_id) do
    page_ids = mypages_group(persona_id).ids
    from(p in Page, where: p.id in ^page_ids)
    |> Repo.all()
  end

  @doc """
  Gets "MyPages" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def subdpages_group(persona_id) do
    Repo.get_by!(PageGroup, name: "SubdPages", persona_id: persona_id)
  end

  @doc """
  Gets "MyPages" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def subd_pages(persona_id) do
    page_ids = subdpages_group(persona_id).ids
    from(p in Page, where: p.id in ^page_ids)
    |> Repo.all()
  end

  @doc """
  Creates a page_group.

  ## Examples

      iex> create_page_group(%{field: value})
      {:ok, %PageGroup{}}

      iex> create_page_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page_group(attrs \\ %{}) do
    %PageGroup{}
    |> PageGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a page_group.

  ## Examples

      iex> update_page_group(page_group, %{field: new_value})
      {:ok, %PageGroup{}}

      iex> update_page_group(page_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page_group(%PageGroup{} = page_group, attrs) do
    page_group
    |> PageGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  TODO
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mypages_group(persona_id, attrs) do
    Repo.get_by!(PageGroup, persona_id: persona_id, name: "MyPages")
    |> PageGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  TODO
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subdpages_group(persona_id, attrs) do
    Repo.get_by!(PageGroup, persona_id: persona_id, name: "SubdPages")
    |> PageGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  TODO
  Deletes a PageGroup.

  ## Examples

      iex> delete_page_group(page_group)
      {:ok, %PageGroup{}}

      iex> delete_page_group(page_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page_group(page_group_name, persona_id) do
    from(p in PageGroup, where: p.id == ^page_group_name and p.persona_id == ^persona_id)
    |> Repo.delete_all
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page_group changes.

  ## Examples

      iex> change_page_group(page_group)
      %Ecto.Changeset{source: %PageGroup{}}

  """
  def change_page_group(%PageGroup{} = page_group) do
    PageGroup.changeset(page_group, %{})
  end

  alias Worldbadges.Features.Badge
  alias Worldbadges.Groups.BadgeGroup

  @doc """
  Returns the list of badge_groups.

  ## Examples

      iex> list_badge_groups()
      [%BadgeGroup{}, ...]

  """
  def list_badge_groups do
    Repo.all(BadgeGroup)
  end

  @doc """
  Gets a single badge_group.

  Raises `Ecto.NoResultsError` if the Badge group does not exist.

  ## Examples

      iex> get_badge_group!(123)
      %BadgeGroup{}

      iex> get_badge_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge_group!(id), do: Repo.get!(BadgeGroup, id)

  @doc """
  TODO: doc
  Gets a single badge_group.

  Raises `Ecto.NoResultsError` if the Badge group does not exist.

  ## Examples

      iex> get_badge_group!(123)
      %BadgeGroup{}

      iex> get_badge_group!(456)
      ** (Ecto.NoResultsError)

  """
  def general_badges_group(), do: Repo.get_by!(BadgeGroup, name: "General badges")
  def my_general_badges_group(persona_id), do: Repo.get_by!(BadgeGroup, name: "MyGeneralBadges", persona_id: persona_id)

  @doc """
  TODO: doc
  Gets a single badge_group.

  Raises `Ecto.NoResultsError` if the Badge group does not exist.

  ## Examples

      iex> get_badge_group!(123)
      %BadgeGroup{}

      iex> get_badge_group!(456)
      ** (Ecto.NoResultsError)

  """
  def general_badges() do
    badge_ids = general_badges_group().ids
    from(b in Badge, where: b.id in ^badge_ids)
    |> Repo.all()
  end

  @doc """
  Gets "MyWorldbadges" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def mybadges_group(persona_id) do
    Repo.get_by!(BadgeGroup, name: "MyBadges", persona_id: persona_id)
  end

  @doc """
  Gets "MyWorldbadges" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def my_badges(persona_id) do
    badge_ids = mybadges_group(persona_id).ids
    from(b in Badge, where: b.id in ^badge_ids)
    |> Repo.all()
  end

  @doc """
  Gets "MyWorldbadges" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  TODO improve examples
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def mygeneralbadges_group(persona_id) do
    Repo.get_by!(BadgeGroup, name: "MyGeneralBadges", persona_id: persona_id)
  end

  # TODO doc
  def subd_badges(persona_id) do
    from(b in Badge,
      where: b.id == fragment("any((SELECT ids FROM badge_groups WHERE persona_id = ? AND name = 'MyBadges')::int[])", ^persona_id)
      or b.id == fragment("any((SELECT ids FROM badge_groups WHERE persona_id = ? AND name = 'MyGeneralBadges')::int[])", ^persona_id)
    ) |> Repo.all()
  end

  @doc """
  TODO
  Gets "MyWorldbadges" page_group.

  Raises `Ecto.NoResultsError` if the Page group does not exist.
  ## Examples

      iex> get_page_group!(123)
      %PageGroup{}

      iex> get_page_group!(456)
      ** (Ecto.NoResultsError)

  """
  def persona_badges(persona_id) do
    from(b in Badge, where: b.persona_id == ^persona_id)
    |> Repo.all()
  end

  @doc """
  Creates a badge_group.

  ## Examples

      iex> create_badge_group(%{field: value})
      {:ok, %BadgeGroup{}}

      iex> create_badge_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge_group(attrs \\ %{}) do
    %BadgeGroup{}
    |> BadgeGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge_group.

  ## Examples

      iex> dge_group(badge_group, %{field: new_value})
      {:ok, %BadgeGroup{}}

      iex> update_badge_group(badge_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mygeneralbadges_group(persona_id, attrs) do
    Repo.get_by!(BadgeGroup, persona_id: persona_id, name: "MyGeneralBadges")
    |> BadgeGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BadgeGroup.

  ## Examples

      iex> delete_badge_group(badge_group)
      {:ok, %BadgeGroup{}}

      iex> delete_badge_group(badge_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge_group(%BadgeGroup{} = badge_group) do
    Repo.delete(badge_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge_group changes.

  ## Examples

      iex> change_badge_group(badge_group)
      %Ecto.Changeset{source: %BadgeGroup{}}

  """
  def change_badge_group(%BadgeGroup{} = badge_group) do
    BadgeGroup.changeset(badge_group, %{})
  end

  alias Worldbadges.Groups.Contact

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def list_contacts do
    Repo.all(Contact)
  end

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def contact_group_for(persona_id), do: Repo.get_by!(Contact, persona_id: persona_id)

  def contact_ids_for(persona_id), do: Repo.get_by!(Contact, persona_id: persona_id) |> contact_ids()

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def contacts_for(object) do
    # TODO: on delete of an account make sure to clean contact lists first to avoid errors
    contact = if object.__struct__ == Contact, do: object, else: object.contact
    contact_ids(contact)
    |> Worldbadges.Accounts.get_personas()
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id), do: Repo.get!(Contact, id)

  # TODO: documentation
  # def get_contact_data(persona_id, page_id) do
  #   query = "SELECT u.id, u.name, u.image" <>
  #           "FROM personas AS u INNER JOIN privacy ON privacy.persona_id = u.id INNER JOIN page_groups ON page_groups.persona_id = u.id AND page_groups.name = 'SubdPages'" <>
  #           "WHERE u.id = ANY((SELECT ids FROM contacts WHERE persona_id = #{persona_id})::int[]) AND NOT privacy.settings @> '{\"show\":\"separated\"}' AND #{page_id} = ANY(page_groups.ids)"
  #
  #   Ecto.Adapters.SQL.query!(Repo, query).rows |> process()
  # end
  # def get_page_members(page_id, persona_id) do
  #   from(u in Worldbadges.Accounts.Persona,
  #     join: p in Worldbadges.Settings.Privacy, on: u.id == p.persona_id,
  #     join: pg in PageGroup, on: u.id == pg.persona_id and pg.name == "SubdPages",
  #     where: u.id == fragment("any((SELECT ids FROM contacts WHERE persona_id = ?)::int[])", ^persona_id) and
  #     not fragment("? @> '{\"show\":\"separated\"}'", p.settings) and
  #     ^page_id in pg.ids
  #   ) |> Repo.all()
  # end

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Contact.

  ## Examples

      iex> delete_contact(contact)
      {:ok, %Contact{}}

      iex> delete_contact(contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{source: %Contact{}}

  """
  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end


  def contact_for(persona_ids) do
    from(g in Contact, where: g.persona_id in ^persona_ids) |> Repo.all()
  end

  alias Worldbadges.Groups.Blocked

  @doc """
  Returns the list of blocked.

  ## Examples

      iex> list_blocked()
      [%Blocked{}, ...]

  """
  def list_blocked do
    Repo.all(Blocked)
  end

  @doc """
  Gets a single blocked.

  Raises `Ecto.NoResultsError` if the Blocked does not exist.

  ## Examples

      iex> get_blocked!(123)
      %Blocked{}

      iex> get_blocked!(456)
      ** (Ecto.NoResultsError)

  """
  def get_blocked!(id), do: Repo.get!(Blocked, id)

  # TODO: doc
  def is_blocked(persona_id, current_persona_id) do
    from(b in Blocked, where: b.persona_id == ^current_persona_id and ^persona_id in b.ids, select: true)
    |> Repo.one()
  end

  @doc """
  Creates a blocked.

  ## Examples

      iex> create_blocked(%{field: value})
      {:ok, %Blocked{}}

      iex> create_blocked(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_blocked(attrs \\ %{}) do
    %Blocked{}
    |> Blocked.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a blocked.

  ## Examples

      iex> update_blocked(blocked, %{field: new_value})
      {:ok, %Blocked{}}

      iex> update_blocked(blocked, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_blocked(%Blocked{} = blocked, attrs) do
    blocked
    |> Blocked.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Blocked.

  ## Examples

      iex> delete_blocked(blocked)
      {:ok, %Blocked{}}

      iex> delete_blocked(blocked)
      {:error, %Ecto.Changeset{}}

  """
  def delete_blocked(%Blocked{} = blocked) do
    Repo.delete(blocked)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking blocked changes.

  ## Examples

      iex> change_blocked(blocked)
      %Ecto.Changeset{source: %Blocked{}}

  """
  def change_blocked(%Blocked{} = blocked) do
    Blocked.changeset(blocked, %{})
  end

  # def for(persona_id, include_reserved? \\ false) do
  #   reserved_names = unless include_reserved?,
  #   do: ["General pages", "MyPages", "SubdPages", "General badges", "MyWorldbadges", "MyGeneralWorldbadges"], else: []
  #
  #   page_groups = from(p in PageGroup, where: p.persona_id == ^persona_id and not p.name in ^reserved_names) |> Repo.all()
  #   persona_groups = from(u in PersonaGroup, where: u.persona_id == ^persona_id and not u.name in ^reserved_names) |> Repo.all()
  #
  #   [page_groups, persona_groups]
  # end

  alias Worldbadges.Groups.Chat

  @doc """
  Returns the list of chats.

  ## Examples

      iex> list_chats()
      [%Chat{}, ...]

  """
  def list_chats do
    Repo.all(Chat)
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id), do: Repo.get!(Chat, id)

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{source: %Chat{}}

  """
  def change_chat(%Chat{} = chat) do
    Chat.changeset(chat, %{})
  end

  alias Worldbadges.Groups.MissedContact

  @doc """
  Returns the list of missed_contacts.

  ## Examples

      iex> list_missed_contacts()
      [%MissedContact{}, ...]

  """
  def list_missed_contacts do
    Repo.all(MissedContact)
  end

  @doc """
  Gets a single missed_contact.

  Raises `Ecto.NoResultsError` if the Missed contact does not exist.

  ## Examples

      iex> get_missed_contact!(123)
      %MissedContact{}

      iex> get_missed_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_missed_contact!(id), do: Repo.get!(MissedContact, id)

  @doc """
  Creates a missed_contact.

  ## Examples

      iex> create_missed_contact(%{field: value})
      {:ok, %MissedContact{}}

      iex> create_missed_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_missed_contact(attrs \\ %{}) do
    %MissedContact{}
    |> MissedContact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a missed_contact.

  ## Examples

      iex> update_missed_contact(missed_contact, %{field: new_value})
      {:ok, %MissedContact{}}

      iex> update_missed_contact(missed_contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_missed_contact(%MissedContact{} = missed_contact, attrs) do
    missed_contact
    |> MissedContact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MissedContact.

  ## Examples

      iex> delete_missed_contact(missed_contact)
      {:ok, %MissedContact{}}

      iex> delete_missed_contact(missed_contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_missed_contact(%MissedContact{} = missed_contact) do
    Repo.delete(missed_contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking missed_contact changes.

  ## Examples

      iex> change_missed_contact(missed_contact)
      %Ecto.Changeset{source: %MissedContact{}}

  """
  def change_missed_contact(%MissedContact{} = missed_contact) do
    MissedContact.changeset(missed_contact, %{})
  end

  alias Worldbadges.Groups.PendingPersona

  @doc """
  Returns the list of pending_personas.

  ## Examples

      iex> list_pending_personas()
      [%PendingPersona{}, ...]

  """
  def list_pending_personas do
    Repo.all(PendingPersona)
  end

  @doc """
  Gets a single pending_persona.

  Raises `Ecto.NoResultsError` if the Pending persona does not exist.

  ## Examples

      iex> get_pending_persona!(123)
      %PendingPersona{}

      iex> get_pending_persona!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pending_persona!(id), do: Repo.get!(PendingPersona, id)

  @doc """
  Creates a pending_persona.

  ## Examples

      iex> create_pending_persona(%{field: value})
      {:ok, %PendingPersona{}}

      iex> create_pending_persona(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pending_persona(attrs \\ %{}) do
    %PendingPersona{}
    |> PendingPersona.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pending_persona.

  ## Examples

      iex> update_pending_persona(pending_persona, %{field: new_value})
      {:ok, %PendingPersona{}}

      iex> update_pending_persona(pending_persona, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pending_persona(%PendingPersona{} = pending_persona, attrs) do
    pending_persona
    |> PendingPersona.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PendingPersona.

  ## Examples

      iex> delete_pending_persona(pending_persona)
      {:ok, %PendingPersona{}}

      iex> delete_pending_persona(pending_persona)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pending_persona(%PendingPersona{} = pending_persona) do
    Repo.delete(pending_persona)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pending_persona changes.

  ## Examples

      iex> change_pending_persona(pending_persona)
      %Ecto.Changeset{source: %PendingPersona{}}

  """
  def change_pending_persona(%PendingPersona{} = pending_persona) do
    PendingPersona.changeset(pending_persona, %{})
  end
end
