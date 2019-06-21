defmodule Worldbadges.Accounts do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import WorldbadgesWeb.Shared, only: [allocate_name: 0]

  import Ecto.Query, warn: false
  alias Worldbadges.Repo
  alias Ecto.Multi

  alias Worldbadges.Accounts.Persona
  alias Worldbadges.{
    Accounts,
    Features,
    Groups,
    Information,
    Information.Case,
    Joins,
    Operations,
    Posting,
    Settings
  }

  @doc """
  Returns the list of personas.

  ## Examples

      iex> list_personas()
      [%Persona{}, ...]

  """
  def list_personas do
    Repo.all(Persona)
  end

  def profile_image_exists?(image) do
    from(p in Persona, where: p.image == ^image, select: true)
    |> Repo.one()
  end

  @doc """
  Gets a single persona.

  Raises `Ecto.NoResultsError` if the Persona does not exist.

  ## Examples

      iex> get_persona!(123)
      %Persona{}

      iex> get_persona!(456)
      ** (Ecto.NoResultsError)

  """
  def get_persona!(id), do: Repo.get!(Persona, id)

  @doc """
  TODO
  Gets a single persona.

  Raises `Ecto.NoResultsError` if the Persona does not exist.

  ## Examples

      iex> get_persona!(123)
      %Persona{}

      iex> get_persona!(456)
      ** (Ecto.NoResultsError)

  """
  def get_personas(persona_ids) do
    from(p in Persona, where: p.id in ^persona_ids, order_by: fragment("lower(?)", p.name))
    |> Repo.all()
  end

  @doc """
  Gets a single persona by name.

  Raises `Ecto.NoResultsError` if the Persona does not exist.

  ## Examples

      iex> get_persona_by_key!("Leger")
      %Persona{}

      iex> get_persona_by_key!("Bad forma+ed key")
      ** (Ecto.NoResultsError)

  """
  def get_persona!(id) do
    Repo.get_by!(Persona, id: id)
  end

  # TODO: documentation
  def get_persona(id) do
    Repo.get_by(Persona, id: id)
  end

  # TODO: document
  def get_personas_by_page(page_id) do
    from(p in Persona,
      join: pp in Worldbadges.Joins.PagePersona, on: p.id == pp.persona_id and pp.page_id == ^page_id
    ) |> Repo.all()
  end

  # TODO: document
  def get_personas_by_user(user_id, excepted_ids \\ []) do
    from(p in Persona, where: p.user_id == ^user_id and not p.id in ^excepted_ids, order_by: p.id)
    |> Repo.all()
  end

  # TODO document
  # SELECT image, name, id
  # FROM personas AS u INNER JOIN privacy AS p ON u.id = p.persona_id
  # WHERE (u.name ILIKE '%#{input}%' OR u.id ILIKE '%#{input}%') AND u.delete = FALSE AND NOT p.settings ->> 'show' = 'separated'
  # def search_personas(general_page_ids, input, persona_id) when general_page_ids == [] do
  #   contact_ids = Groups.contact_ids_for(persona_id)
  #   from(p in Persona,
  #     join: pr in Worldbadges.Settings.Privacy, on: p.id == pr.persona_id,
  #     # where: (ilike(u.name, ^input) or ilike(u.id, ^input)) and
  #     where: not p.id in ^contact_ids and ilike(p.name, ^input) and
  #     not fragment("? @> '{\"show\":\"separated\"}'", pr.settings)
  #   ) |> Repo.all()
  # end
  #
  # def search_personas(general_page_ids, input, persona_id) do
  #   general_page_ids = Enum.map(general_page_ids, &(String.to_integer(&1)))
  #   contact_ids = Groups.contact_ids_for(persona_id)
  #   from(p in Persona,
  #     join: pr in Worldbadges.Settings.Privacy, on: p.id == pr.persona_id,
  #     join: pg in Worldbadges.Groups.PageGroup, on: p.id == pg.persona_id and pg.name == "SubdPages" and fragment("? && ?", ^general_page_ids, pg.ids),
  #     # where: (ilike(u.name, ^input) or ilike(u.id, ^input)) and
  #     where: not p.id in ^contact_ids and ilike(p.name, ^input) and
  #     not fragment("? @> '{\"show\":\"separated\"}'", pr.settings)
  #   ) |> Repo.all()
  # end

  def search_personas(general_page_ids, input) when general_page_ids == [] do
    from(p in Persona,
      join: pr in Worldbadges.Settings.Privacy, on: p.id == pr.persona_id,
      # where: (ilike(u.name, ^input) or ilike(u.id, ^input)) and
      where: ilike(p.name, ^input) and not fragment("? @> '{\"show\":\"separated\"}'", pr.settings)
    ) |> Repo.all()
  end

  def search_personas(general_page_ids, input) do
    general_page_ids = Enum.map(general_page_ids, &(String.to_integer(&1)))
    from(p in Persona,
      join: pr in Worldbadges.Settings.Privacy, on: p.id == pr.persona_id,
      join: pg in Worldbadges.Groups.PageGroup, on: p.id == pg.persona_id and pg.name == "SubdPages" and fragment("? && ?", ^general_page_ids, pg.ids),
      # where: (ilike(u.name, ^input) or ilike(u.id, ^input)) and
      where: ilike(p.name, ^input) and not fragment("? @> '{\"show\":\"separated\"}'", pr.settings)
    ) |> Repo.all()
  end

  # TODO documentation
  def search_non_members(input, page_id) do
    from(p in Persona,
      join: pr in Worldbadges.Settings.Privacy, on: p.id == pr.persona_id,
      join: pg in Worldbadges.Groups.PageGroup, on: p.id == pg.persona_id and
      pg.name == "SubdPages" and not ^page_id in pg.ids,
      join: pu in Worldbadges.Groups.PendingPersona, on: pu.page_id == ^page_id and not (p.id in pu.invites or p.id in pu.requests),
      # where: (ilike(u.name, ^input) or ilike(u.id, ^input)) and
      where: ilike(p.name, ^input) and
      not fragment("? @> '{\"show\":\"separated\"}'", pr.settings)
    ) |> Repo.all()
  end

  @doc """
  Creates a persona.

  ## Examples

      iex> create_persona(%{field: value})
      {:ok, %Persona{}}

      iex> create_persona(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_persona(attrs \\ %{}) do
    %Persona{}
    |> Persona.changeset(attrs)
    |> Repo.insert()
  end

  def create_persona_associated_data(persona_id) do
    Multi.new
    |> Multi.insert(:recognition_total, Features.RecognitionTotal.changeset(%Features.RecognitionTotal{}, %{persona_id: persona_id, json: %{}}))
    |> Multi.insert(:blocked, Groups.Blocked.changeset(%Groups.Blocked{}, %{persona_id: persona_id, ids: []}))
    |> Multi.insert(:contact, Groups.Contact.changeset(%Groups.Contact{}, %{persona_id: persona_id, groups: %{"0" => [], "1" => []}}))
    |> Multi.insert(:missed_contact, Groups.MissedContact.changeset(%Groups.MissedContact{}, %{persona_id: persona_id, ids: []}))
    |> Multi.insert(:my_badges_group, Groups.BadgeGroup.changeset(%Groups.BadgeGroup{}, %{persona_id: persona_id, ids: [], name: "MyBadges"}))
    |> Multi.insert(:my_general_badges_group, Groups.BadgeGroup.changeset(%Groups.BadgeGroup{}, %{persona_id: persona_id, ids: [1], name: "MyGeneralBadges"}))
    |> Multi.insert(:my_pages_group, Groups.PageGroup.changeset(%Groups.PageGroup{}, %{persona_id: persona_id, ids: [], name: "MyPages"}))
    |> Multi.insert(:my_subd_pages_group, Groups.PageGroup.changeset(%Groups.PageGroup{}, %{persona_id: persona_id, ids: [1], name: "SubdPages"}))
    |> Multi.insert(:join_page, Joins.PagePersona.changeset(%Joins.PagePersona{}, %{page_id: 1, persona_id: persona_id}))
    |> Multi.insert(:badge_base, Information.BadgeBase.changeset(%Information.BadgeBase{}, %{image: allocate_name(), persona_id: persona_id}))
    |> Multi.insert(:consent, Information.Consent.changeset(%Information.Consent{}, %{consented: true, persona_id: persona_id}))
    |> Multi.insert(:total_event, Information.TotalEvent.changeset(%Information.TotalEvent{}, %{total: 0, persona_id: persona_id}))
    |> Multi.insert(:style, Settings.Style.changeset(%Settings.Style{}, %{persona_id: persona_id, settings: %{color: "purple", bg: "#d1c5d0", ad: "survival", layout: "timewise"}}))
    |> Multi.insert(:privacy, Settings.Privacy.changeset(%Settings.Privacy{}, %{persona_id: persona_id, settings: %{see: "open", show: "open", notifications: "connected"}}))
    |> Repo.transaction()
  end

  @doc """
  Updates a persona.

  ## Examples

      iex> update_persona(persona, %{field: new_value})
      {:ok, %Persona{}}

      iex> update_persona(persona, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_persona(%Persona{} = persona, attrs) do
    persona
    |> Persona.changeset(attrs)
    |> Repo.update()
  end

  # TODO doc
  def update_left_at(persona_id) do
    time = Timex.now
    from(p in Persona, where: p.id == ^persona_id)
    |> Repo.update_all(set: [updated_at: time, left_at: time])
  end

  @doc """
  Deletes a Persona.

  ## Examples

      iex> delete_persona(persona)
      {:ok, %Persona{}}

      iex> delete_persona(persona)
      {:error, %Ecto.Changeset{}}

  """
  def delete_persona(%Persona{} = persona) do
    Repo.delete(persona)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking persona changes.

  ## Examples

      iex> change_persona(persona)
      %Ecto.Changeset{source: %Persona{}}

  """
  def change_persona(%Persona{} = persona) do
    Persona.changeset(persona, %{})
  end

  alias Worldbadges.Accounts.User

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end
