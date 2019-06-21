defmodule Worldbadges.Information do
  @moduledoc """
  The Information context.
  """

  import Ecto.Query, warn: false
  import WorldbadgesWeb.Shared, only: [parse_name: 1]
  alias Worldbadges.Repo

  alias Worldbadges.Information.Event

  def get_chat_events([], recipient_id), do: []

  def get_chat_events(persona_ids, recipient_id) do
    ids_string = Enum.join(persona_ids, ",")
    query = "SELECT p.id, p.image, p.name,
    (SELECT m.content FROM messages AS m WHERE m.recipient_id = #{recipient_id} AND m.persona_id = p.id ORDER BY m.inserted_at DESC LIMIT 1)" <>
            " FROM personas AS p" <>
            " WHERE p.id IN (#{ids_string})"

    Ecto.Adapters.SQL.query!(Repo, query).rows
    |> Enum.map(fn(row) ->
      %{
        id:       Enum.at(row, 0),
        image:    Enum.at(row, 1),
        name:     Enum.at(row, 2),
        content:  Enum.at(row, 3)
      }
    end)
  end

  def get_events(persona, limit) do
    persona_id = persona.id
    left_at = persona.left_at
    # left_at = if persona.new_left_at.day == Timex.now().day, do: persona.old_left_at, else: Accounts.update_persona(persona, %{left_at: Timex.now()})
    query = "(SELECT c.inserted_at as o, 5, p.name, p.image, pg.name, pg.image, c.id, c.content, c.article_id, p.id" <>
            " FROM comments as c INNER JOIN personas as p ON p.id = c.persona_id LEFT OUTER JOIN pages as pg ON pg.id = c.page_id" <>
            " WHERE c.persona_id <> #{persona_id} AND (c.article_id in (SELECT article_id FROM interest_articles WHERE persona_id = #{persona_id}) OR c.author_id = '#{persona_id}') AND c.inserted_at > TIMESTAMP '#{left_at}')" <>

            # " UNION" <>
            #
            # "(SELECT a.updated_at as o, 2, NULL, NULL, p.name, p.image, a.article_id, NULL" <>
            # " FROM article_approvals as a INNER JOIN personas as u ON u.id = a.persona_id INNER JOIN pages as p ON p.id = a.page_id" <>
            # " WHERE a.persona_id = #{persona_id} AND a.updated_at > TIMESTAMP '#{left_at}')" <>
            #
            # " UNION" <>
            #
            # "(SELECT c.updated_at as o, 3, NULL, NULL, p.name, p.image, c.comment_id, NULL" <>
            # " FROM comment_approvals as c INNER JOIN personas as u ON u.id = c.persona_id INNER JOIN pages as p ON p.id = c.page_id" <>
            # " WHERE c.persona_id = #{persona_id} AND c.updated_at > TIMESTAMP '#{left_at}')"  <>
            #
            " UNION" <>

            "(SELECT a.updated_at as o, 4, p.name, p.image, NULL, NULL, a.id, a.status, NULL, NULL" <>
            " FROM ads as a INNER JOIN personas as p ON p.id = a.persona_id" <>
            " WHERE a.persona_id = #{persona_id} AND a.updated_at > TIMESTAMP '#{left_at}')"  <>

            " UNION" <>

            "(SELECT r.inserted_at as o, 1, p.name, p.image, pg.name, pg.image, r.article_id, NULL, NULL, NULL" <>
            " FROM recognitions as r INNER JOIN personas as p ON p.id = r.persona_id INNER JOIN pages as pg ON pg.id = r.page_id" <>
            " WHERE r.receiver_id = #{persona_id} AND r.inserted_at > TIMESTAMP '#{left_at}')" <>

            " UNION" <>

            "(SELECT a.inserted_at as o, 6, p.name, p.image, NULL, NULL, p.id, NULL, NULL, NULL" <>
            " FROM add_contacts as a INNER JOIN personas as p ON p.id = a.requester" <>
            " WHERE a.requested = #{persona_id} AND a.inserted_at > TIMESTAMP '#{left_at}')"  <>

            " UNION" <>

            "(SELECT n.inserted_at as o, n.action, p.name, p.image, pg.name, pg.image, n.id, n.link, NULL, NULL" <>
            " FROM notifications_personas as ns INNER JOIN notifications as n ON n.id = ns.notification_id LEFT OUTER JOIN personas as p ON p.id = n.persona_id LEFT OUTER JOIN pages as pg ON pg.id = n.page_id" <>
            " WHERE ns.persona_id = #{persona_id} AND n.inserted_at > TIMESTAMP '#{left_at}')"  <>

            " ORDER BY o DESC" <>
            " LIMIT #{limit}"

    Ecto.Adapters.SQL.query!(Repo, query).rows |> process_events(persona)
  end

  defp process_events(rows, persona) do
    Enum.map(rows, fn(row) ->
      # description, link, content
      [d,l,c] = case Enum.at(row, 1) do
        1  -> ["Sent recognition", "/page/#{parse_name(Enum.at(row, 4))}/#{Enum.at(row, 6)}", nil]
        # disabled as to avoid addiction and annoince
        # 2  -> ["New approval status",  "/article/#{Enum.at(row, 6)}", nil]
        # 3  -> ["New approval status",  "/comment/#{Enum.at(row, 6)}", nil]
        4  -> [description, content] = Enum.at(row, 7) |> String.split(":"); ["Ad #{description}", "ad/#{Enum.at(row, 6)}", content]
        5  ->
          article_id = Enum.at(row, 8);
          comment_id = Enum.at(row, 6);
          page_name = if name = Enum.at(row, 4), do: parse_name(name)
          persona_id = Enum.at(row, 9)
          prefix = if page_name, do: "/page/#{page_name}", else: "/persona/#{persona_id}"
          link = "#{prefix}/#{article_id}/#{comment_id}/#comment_#{comment_id}"
          ["New comment", link, Enum.at(row, 7)]
        6  -> ["New contact request", "/persona/#{Enum.at(row, 6)}", nil]
        7  -> ["New join request", Enum.at(row, 7), nil]
        8  -> ["New contact", Enum.at(row, 7), nil]
        9  -> ["New member", Enum.at(row, 7), nil]
        10 -> ["New join invitation", Enum.at(row, 7), nil]
        11 -> ["Accepted join request", Enum.at(row, 7), nil]
        12 -> ["Flagged content", Enum.at(row, 7), nil]
        13 -> ["Removed from page", Enum.at(row, 7), nil]
      end
      to_struct(row,d,l,c)
    end)
  end

  defp to_struct(row, description, link, content) do
    %Event{
      time: Enum.at(row, 0),
      description: description,
      name: Enum.at(row, 2),
      image: Enum.at(row, 3),
      page_name: Enum.at(row, 4),
      page_image: Enum.at(row, 5),
      link: link,
      content: content
    }
  end

  # def search_results(input) do
  #   query = "(SELECT image, name, NULL " <>
  #           " FROM pages" <>
  #           " WHERE name ilike '%#{input}%')" <>
  #
  #           " UNION" <>
  #
  #           "(SELECT image, name, id" <>
  #           " FROM personas as u INNER JOIN privacy as p ON u.id = p.persona_id" <>
  #           " WHERE (u.name ilike '%#{input}%' OR u.id ilike '%#{input}%') AND u.delete = false AND NOT p.settings ->> 'show' = 'separated')"
  #
  #   Ecto.Adapters.SQL.query!(Repo, query).rows |> process_search_results()
  # end
  #
  # defp process_search_results(rows) do
  #   Enum.map(rows, fn(row) ->
  #     %{
  #       image: Enum.at(row, 0),
  #       name: Enum.at(row, 1),
  #       id: Enum.at(row, 2)
  #     }
  #   end)
  # end

  alias Worldbadges.Information.AddContact

  @doc """
  Returns the list of add_contacts.

  ## Examples

      iex> list_add_contacts()
      [%AddContact{}, ...]

  """
  def list_add_contacts do
    Repo.all(AddContact)
  end

  @doc """
  TODO
  Gets a single add_contact.

  Raises `Ecto.NoResultsError` if the Add contact does not exist.

  ## Examples

      iex> get_add_contact!(123)
      %AddContact{}

      iex> get_add_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_add_contact(requester, requested) do
    Repo.get_by(AddContact, requester: requester, requested: requested)
  end

  @doc """
  TODO
  Gets a single add_contact.

  Raises `Ecto.NoResultsError` if the Add contact does not exist.

  ## Examples

      iex> get_add_contact!(123)
      %AddContact{}

      iex> get_add_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_any_add_contact(persona_id1, persona_id2) do
    record = Repo.get_by(AddContact, requester: persona_id1, requested: persona_id2)
    if record, do: record, else: Repo.get_by(AddContact, requester: persona_id2, requested: persona_id1)
  end

  @doc """
  Creates a add_contact.

  ## Examples

      iex> create_add_contact(%{field: value})
      {:ok, %AddContact{}}

      iex> create_add_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_add_contact(attrs \\ %{}) do
    %AddContact{}
    |> AddContact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a add_contact.

  ## Examples

      iex> update_add_contact(add_contact, %{field: new_value})
      {:ok, %AddContact{}}

      iex> update_add_contact(add_contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_add_contact(%AddContact{} = add_contact, attrs) do
    add_contact
    |> AddContact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AddContact.

  ## Examples

      iex> delete_add_contact(add_contact)
      {:ok, %AddContact{}}

      iex> delete_add_contact(add_contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_add_contact(add_contact) do
    requester = add_contact.requester
    requested = add_contact.requested

    from(a in AddContact, where: a.requester == ^requester and a.requested == ^requested)
    |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking add_contact changes.

  ## Examples

      iex> change_add_contact(add_contact)
      %Ecto.Changeset{source: %AddContact{}}

  """
  def change_add_contact(%AddContact{} = add_contact) do
    AddContact.changeset(add_contact, %{})
  end

  alias Worldbadges.Information.Notification

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  TODO
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def notifications(persona_id, left_at) do
    from(n in Notification, where: n.persona_id == ^persona_id and n.inserted_at > ^left_at)
    |> Repo.all()
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{source: %Notification{}}

  """
  def change_notification(%Notification{} = notification) do
    Notification.changeset(notification, %{})
  end

  alias Worldbadges.Information.InterestArticle

  @doc """
  Returns the list of interest_articles.

  ## Examples

      iex> list_interest_articles()
      [%InterestArticle{}, ...]

  """
  def list_interest_articles do
    Repo.all(InterestArticle)
  end

  @doc """
  Gets a single interest_article.

  Raises `Ecto.NoResultsError` if the Interest article does not exist.

  ## Examples

      iex> get_interest_article!(123)
      %InterestArticle{}

      iex> get_interest_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_interest_article(article_id, persona_id) do
    Repo.get_by(InterestArticle, article_id: article_id, persona_id: persona_id)
  end

  @doc """
  Creates a interest_article.

  ## Examples

      iex> create_interest_article(%{field: value})
      {:ok, %InterestArticle{}}

      iex> create_interest_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_interest_article(%{expiry_at: expiry_at, article_id: article_id, persona_id: persona_id} = attrs) do
    unless get_interest_article(article_id, persona_id) do
      %InterestArticle{}
      |> InterestArticle.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Updates a interest_article.

  ## Examples

      iex> update_interest_article(interest_article, %{field: new_value})
      {:ok, %InterestArticle{}}

      iex> update_interest_article(interest_article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_interest_article(%InterestArticle{} = interest_article, attrs) do
    interest_article
    |> InterestArticle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a InterestArticle.

  ## Examples

      iex> delete_interest_article(interest_article)
      {:ok, %InterestArticle{}}

      iex> delete_interest_article(interest_article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_interest_article(%InterestArticle{} = interest_article) do
    Repo.delete(interest_article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking interest_article changes.

  ## Examples

      iex> change_interest_article(interest_article)
      %Ecto.Changeset{source: %InterestArticle{}}

  """
  def change_interest_article(%InterestArticle{} = interest_article) do
    InterestArticle.changeset(interest_article, %{})
  end

  alias Worldbadges.Information.BadgeBase

  @doc """
  Returns the list of badge_bases.

  ## Examples

      iex> list_badge_bases()
      [%BadgeBase{}, ...]

  """
  def list_badge_bases do
    Repo.all(BadgeBase)
  end

  @doc """
  Gets a single badge_base.

  Raises `Ecto.NoResultsError` if the Badge base does not exist.

  ## Examples

      iex> get_badge_base!(123)
      %BadgeBase{}

      iex> get_badge_base!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge_base!(id), do: Repo.get!(BadgeBase, id)

  @doc """
  Creates a badge_base.

  ## Examples

      iex> create_badge_base(%{field: value})
      {:ok, %BadgeBase{}}

      iex> create_badge_base(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge_base(attrs \\ %{}) do
    %BadgeBase{}
    |> BadgeBase.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge_base.

  ## Examples

      iex> update_badge_base(badge_base, %{field: new_value})
      {:ok, %BadgeBase{}}

      iex> update_badge_base(badge_base, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge_base(%BadgeBase{} = badge_base, attrs) do
    badge_base
    |> BadgeBase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BadgeBase.

  ## Examples

      iex> delete_badge_base(badge_base)
      {:ok, %BadgeBase{}}

      iex> delete_badge_base(badge_base)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge_base(%BadgeBase{} = badge_base) do
    Repo.delete(badge_base)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge_base changes.

  ## Examples

      iex> change_badge_base(badge_base)
      %Ecto.Changeset{source: %BadgeBase{}}

  """
  def change_badge_base(%BadgeBase{} = badge_base) do
    BadgeBase.changeset(badge_base, %{})
  end

  alias Worldbadges.Information.Consent

  @doc """
  Returns the list of consents.

  ## Examples

      iex> list_consents()
      [%Consent{}, ...]

  """
  def list_consents do
    Repo.all(Consent)
  end

  @doc """
  Gets a single consent.

  Raises `Ecto.NoResultsError` if the Consent does not exist.

  ## Examples

      iex> get_consent!(123)
      %Consent{}

      iex> get_consent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_consent!(id), do: Repo.get!(Consent, id)

  @doc """
  Creates a consent.

  ## Examples

      iex> create_consent(%{field: value})
      {:ok, %Consent{}}

      iex> create_consent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_consent(attrs \\ %{}) do
    %Consent{}
    |> Consent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a consent.

  ## Examples

      iex> update_consent(consent, %{field: new_value})
      {:ok, %Consent{}}

      iex> update_consent(consent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_consent(%Consent{} = consent, attrs) do
    consent
    |> Consent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Consent.

  ## Examples

      iex> delete_consent(consent)
      {:ok, %Consent{}}

      iex> delete_consent(consent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_consent(%Consent{} = consent) do
    Repo.delete(consent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking consent changes.

  ## Examples

      iex> change_consent(consent)
      %Ecto.Changeset{source: %Consent{}}

  """
  def change_consent(%Consent{} = consent) do
    Consent.changeset(consent, %{})
  end

  alias Worldbadges.Information.TotalEvent

  def get_total_event!(persona_id), do: Repo.get_by!(TotalEvent, persona_id: persona_id)

  def events_total_for!(persona_id), do: get_total_event!(persona_id) |> Map.fetch!(:total)

  def create_total_event(attrs \\ %{}) do
    %TotalEvent{}
    |> TotalEvent.changeset(attrs)
    |> Repo.insert()
  end

  def update_total_event(%TotalEvent{} = consent, attrs) do
    consent
    |> TotalEvent.changeset(attrs)
    |> Repo.update()
  end

  alias Worldbadges.Information.ArticleExpiry

  @doc """
  Returns the list of article_expiry.

  ## Examples

      iex> list_article_expiry()
      [%ArticleExpiry{}, ...]

  """
  def list_article_expiry do
    Repo.all(ArticleExpiry)
  end

  @doc """
  Gets a single article_expiry.

  Raises `Ecto.NoResultsError` if the Article expiry does not exist.

  ## Examples

      iex> get_article_expiry!(123)
      %ArticleExpiry{}

      iex> get_article_expiry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article_expiry!(id), do: Repo.get!(ArticleExpiry, id)

  @doc """
  Creates a article_expiry.

  ## Examples

      iex> create_article_expiry(%{field: value})
      {:ok, %ArticleExpiry{}}

      iex> create_article_expiry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article_expiry(attrs \\ %{}) do
    %ArticleExpiry{}
    |> ArticleExpiry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article_expiry.

  ## Examples

      iex> update_article_expiry(article_expiry, %{field: new_value})
      {:ok, %ArticleExpiry{}}

      iex> update_article_expiry(article_expiry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article_expiry(%ArticleExpiry{} = article_expiry, attrs) do
    article_expiry
    |> ArticleExpiry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ArticleExpiry.

  ## Examples

      iex> delete_article_expiry(article_expiry)
      {:ok, %ArticleExpiry{}}

      iex> delete_article_expiry(article_expiry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article_expiry(%ArticleExpiry{} = article_expiry) do
    Repo.delete(article_expiry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article_expiry changes.

  ## Examples

      iex> change_article_expiry(article_expiry)
      %Ecto.Changeset{source: %ArticleExpiry{}}

  """
  def change_article_expiry(%ArticleExpiry{} = article_expiry) do
    ArticleExpiry.changeset(article_expiry, %{})
  end

  alias Worldbadges.Information.Case

  # TODO doc
  def create_case(attrs \\ %{}) do
    %Case{}
    |> Case.changeset(attrs)
    |> Repo.insert()
  end

  def change_case(%Case{} = case) do
    Case.changeset(case, %{})
  end
end
