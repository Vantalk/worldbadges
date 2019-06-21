defmodule Worldbadges.Joins do
  @moduledoc """
  The Groups context.
  """

    import Ecto.Query, warn: false
  alias Worldbadges.Repo

  alias Worldbadges.Joins.PagePersona

  @doc """
  Returns the list of page_personas.

  ## Examples

      iex> list_page_personas()
      [%PagePersona{}, ...]

  """
  def list_page_personas do
    Repo.all(PagePersona)
  end

  @doc """
  Gets a single page_personas.

  Raises `Ecto.NoResultsError` if the PagePersona does not exist.

  ## Examples

      iex> get_page_personas!(123)
      %PagePersona{}

      iex> get_page_personas!(456)
      ** (Ecto.NoResultsError)

  """
  def get_persona_ids_by_page(page_id) do
    from(p in PagePersona, select: p.persona_id, where: p.page_id == ^page_id)
    |> Repo.all()
  end

  def is_member?(page_id, persona_id) do
    from(p in PagePersona, select: p.persona_id, where: p.page_id == ^page_id and p.persona_id == ^persona_id)
    |> Repo.one()
  end

  @doc """
  Gets a single page_personas.

  Raises `Ecto.NoResultsError` if the PagePersona does not exist.

  ## Examples

      iex> get_page_personas_by_name!('animal_lovers')
      %PagePersona{}

      iex> get_page_personas_by_name!('bad_name')
      ** (Ecto.NoResultsError)

  """
  def get_page_personas_by_name!(name), do: Repo.get_by!(PagePersona, name: name)

  @doc """
  Creates a page_personas.

  ## Examples

      iex> create_page_personas(%{field: value})
      {:ok, %PagePersona{}}

      iex> create_page_personas(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page_personas(attrs \\ %{}) do
    %PagePersona{}
    |> PagePersona.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a page_personas.

  ## Examples

      iex> update_page_personas(page_personas, %{field: new_value})
      {:ok, %PagePersona{}}

      iex> update_page_personas(page_personas, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page_personas(%PagePersona{} = page_personas, attrs) do
    page_personas
    |> PagePersona.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  TODO
  Deletes a PagePersona.

  ## Examples

      iex> delete_page_personas(page_personas)
      {:ok, %PagePersona{}}

      iex> delete_page_personas(page_personas)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page_personas(page_id, persona_id) do
    from(p in PagePersona, where: p.page_id == ^page_id and p.persona_id == ^persona_id) |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page_personas changes.

  ## Examples

      iex> change_page_personas(page_personas)
      %Ecto.Changeset{source: %PagePersona{}}

  """
  def change_page_personas(%PagePersona{} = page_personas) do
    PagePersona.changeset(page_personas, %{})
  end

  alias Worldbadges.Joins.AdBadge
  alias Worldbadges.Posting
  alias Worldbadges.Features.Badge

  @doc """
  Returns the list of ads_badges.

  ## Examples

      iex> list_ads_badges()
      [%AdBadge{}, ...]

  """
  def list_ads_badges do
    Repo.all(AdBadge)
  end

  @doc """
  Gets a single ads_badges.

  Raises `Ecto.NoResultsError` if the AdBadge does not exist.

  ## Examples

      iex> get_ads_badges!(123)
      %AdBadge{}

      iex> get_ads_badges!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ad_ids(badge_ids) do
    from(a in AdBadge, select: a.ad_id, where: a.badge_id in ^badge_ids)
    |> Repo.all()
  end

  @doc """
  Creates a ads_badges.

  ## Examples

      iex> create_ads_badges(%{field: value})
      {:ok, %AdBadge{}}

      iex> create_ads_badges(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ads_badges(attrs \\ %{}) do
    %AdBadge{}
    |> AdBadge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ads_badges.

  ## Examples

      iex> update_ads_badges(ads_badges, %{field: new_value})
      {:ok, %AdBadge{}}

      iex> update_ads_badges(ads_badges, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ads_badges(%AdBadge{} = ads_badges, attrs) do
    ads_badges
    |> AdBadge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AdBadge.

  ## Examples

      iex> delete_ads_badges(ads_badges)
      {:ok, %AdBadge{}}

      iex> delete_ads_badges(ads_badges)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ads_badges(%AdBadge{} = ads_badges) do
    Repo.delete(ads_badges)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ads_badges changes.

  ## Examples

      iex> change_ads_badges(ads_badges)
      %Ecto.Changeset{source: %AdBadge{}}

  """
  def change_ads_badges(%AdBadge{} = ads_badges) do
    AdBadge.changeset(ads_badges, %{})
  end


  alias Worldbadges.Joins.ChatPersona

  @doc """
  Returns the list of chats_personas.

  ## Examples

      iex> list_chats_personas()
      [%ChatPersona{}, ...]

  """
  def list_chats_personas do
    Repo.all(ChatPersona)
  end

  @doc """
  Gets a single chat_persona.

  Raises `Ecto.NoResultsError` if the Chat persona does not exist.

  ## Examples

      iex> get_chat_persona!(123)
      %ChatPersona{}

      iex> get_chat_persona!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat_persona!(id), do: Repo.get!(ChatPersona, id)

  @doc """
  Creates a chat_persona.

  ## Examples

      iex> create_chat_persona(%{field: value})
      {:ok, %ChatPersona{}}

      iex> create_chat_persona(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_persona(attrs \\ %{}) do
    %ChatPersona{}
    |> ChatPersona.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat_persona.

  ## Examples

      iex> update_chat_persona(chat_persona, %{field: new_value})
      {:ok, %ChatPersona{}}

      iex> update_chat_persona(chat_persona, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat_persona(%ChatPersona{} = chat_persona, attrs) do
    chat_persona
    |> ChatPersona.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ChatPersona.

  ## Examples

      iex> delete_chat_persona(chat_persona)
      {:ok, %ChatPersona{}}

      iex> delete_chat_persona(chat_persona)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat_persona(%ChatPersona{} = chat_persona) do
    Repo.delete(chat_persona)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat_persona changes.

  ## Examples

      iex> change_chat_persona(chat_persona)
      %Ecto.Changeset{source: %ChatPersona{}}

  """
  def change_chat_persona(%ChatPersona{} = chat_persona) do
    ChatPersona.changeset(chat_persona, %{})
  end

  alias Worldbadges.Joins.NotificationPersona

  @doc """
  Returns the list of notifications_personas.

  ## Examples

      iex> list_notifications_personas()
      [%NotificationPersona{}, ...]

  """
  def list_notifications_personas do
    Repo.all(NotificationPersona)
  end

  @doc """
  Gets a single notification_persona.

  Raises `Ecto.NoResultsError` if the Notification persona does not exist.

  ## Examples

      iex> get_notification_persona!(123)
      %NotificationPersona{}

      iex> get_notification_persona!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification_persona!(id), do: Repo.get!(NotificationPersona, id)

  @doc """
  Creates a notification_persona.

  ## Examples

      iex> create_notification_persona(%{field: value})
      {:ok, %NotificationPersona{}}

      iex> create_notification_persona(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification_persona(attrs \\ %{}) do
    %NotificationPersona{}
    |> NotificationPersona.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification_persona.

  ## Examples

      iex> update_notification_persona(notification_persona, %{field: new_value})
      {:ok, %NotificationPersona{}}

      iex> update_notification_persona(notification_persona, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification_persona(%NotificationPersona{} = notification_persona, attrs) do
    notification_persona
    |> NotificationPersona.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a NotificationPersona.

  ## Examples

      iex> delete_notification_persona(notification_persona)
      {:ok, %NotificationPersona{}}

      iex> delete_notification_persona(notification_persona)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification_persona(%NotificationPersona{} = notification_persona) do
    Repo.delete(notification_persona)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification_persona changes.

  ## Examples

      iex> change_notification_persona(notification_persona)
      %Ecto.Changeset{source: %NotificationPersona{}}

  """
  def change_notification_persona(%NotificationPersona{} = notification_persona) do
    NotificationPersona.changeset(notification_persona, %{})
  end
end
