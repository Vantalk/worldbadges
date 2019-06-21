defmodule Worldbadges.Posting do
  @moduledoc """
  The Posting context.
  """

  import WorldbadgesWeb.Shared, only: [contact_ids: 1]
  import Ecto.Query, warn: false
  alias Worldbadges.Repo

  alias Worldbadges.Posting.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def comments(persona_id, left_at, interest_articles) do
    article_ids = Enum.map(interest_articles, &(&1.article_id))
    from(c in Comment, where: c.inserted_at == ^left_at, where: c.author_id == ^persona_id or c.article_id in ^article_ids)
    |> Repo.all()
  end

  def comments_for_article(article_id, comment_id, limit, offset) when is_nil(comment_id) do
    IO.inspect "----------------------------1"
    from(c in Comment, where: c.article_id == ^article_id, limit: ^limit, offset: ^offset, order_by: [desc: :id])
    |> Repo.all() |> Enum.reverse() |> Repo.preload(:persona)
  end

  def comments_for_article(article_id, comment_id, around_limit, offset) do
    IO.inspect "----------------------------2"
    previous_comments(article_id, comment_id, around_limit, offset) ++
    next_comments(article_id, comment_id, true, around_limit, offset)
  end

  def previous_comments(article_id, comment_id, limit, offset) do
    IO.inspect "----------------------------3"
    from(c in Comment, where: c.id < ^comment_id and c.article_id == ^article_id, limit: ^limit, offset: ^offset, order_by: [desc: :id])
    |> Repo.all() |> Enum.reverse() |> Repo.preload(:persona)
  end

  def next_comments(article_id, comment_id, true, limit, offset) do
    from(c in Comment, where: c.id >= ^comment_id and c.article_id == ^article_id, limit: ^limit, offset: ^offset, order_by: [asc: :id])
    |> Repo.all() |> Repo.preload(:persona)
  end

  def next_comments(article_id, comment_id, false, limit, offset) do
    from(c in Comment, where: c.id > ^comment_id and c.article_id == ^article_id, limit: ^limit, offset: ^offset, order_by: [asc: :id])
    |> Repo.all() |> Repo.preload(:persona)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Gets all comments for an asociated article, along with persona image and name.

  TODO: update examples for this method

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  # def get_comments(article_id, limit, offset) do
  #   from(c in Comment,
  #     join: u in Worldbadges.Accounts.Persona, on: [id: c.persona_id],
  #     select: {c.id, c.content, c.inserted_at, u.image, u.name},
  #     where: c.article_id == ^article_id,
  #     limit: ^limit,
  #     offset: ^offset,
  #     order_by: [desc: :inserted_at]
  #   ) |> Repo.all()
  # end

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{source: %Comment{}}

  """
  def change_comment(%Comment{} = comment) do
    Comment.changeset(comment, %{})
  end

  alias Worldbadges.Posting.Ad

  @doc """
  Returns the list of ads.

  ## Examples

      iex> list_ads()
      [%Ad{}, ...]

  """
  def list_ads do
    Repo.all(Ad)
  end

  @doc """
  Returns the list of ads.

  ## Examples

      iex> list_ads()
      [%Ad{}, ...]

  """
  def ads_for(persona_id) do
    from(a in Ad, where: a.persona_id == ^persona_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of ads.

  ## Examples

      iex> list_ads()
      [%Ad{}, ...]

  """
  def ads_for(persona_id, left_at) do
    from(a in Ad, where: a.persona_id == ^persona_id and a.updated_at > ^left_at)
    |> Repo.all()
  end

  @doc """
  TODO
  Gets a single ad.

  Raises `Ecto.NoResultsError` if the Ad does not exist.

  ## Examples

      iex> get_ad!(123)
      %Ad{}

      iex> get_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ads!(ids) do
    from(a in Ad, where: a.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Gets a single ad.

  Raises `Ecto.NoResultsError` if the Ad does not exist.

  ## Examples

      iex> get_ad!(123)
      %Ad{}

      iex> get_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ad!(id), do: Repo.get!(Ad, id)

  @doc """
  Gets a single ad.

  Raises `Ecto.NoResultsError` if the Ad does not exist.

  ## Examples

      iex> get_ad!(123)
      %Ad{}

      iex> get_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ad(name, persona_id), do: Repo.get_by(Ad, name: name, persona_id: persona_id)

  @doc """
  Gets a single ad.

  Raises `Ecto.NoResultsError` if the Ad does not exist.

  ## Examples

      iex> get_ad!(123)
      %Ad{}

      iex> get_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ad!(name, persona_id), do: Repo.get_by!(Ad, name: name, persona_id: persona_id)

  @doc """
  TODO Update implementation to make really random
  Gets a random ad.

  Raises `Ecto.NoResultsError` if the Ad does not exist.

  ## Examples

      iex> get_ad!(123)
      %Ad{}

      iex> get_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_random_ad(badge_ids) do
    # Also get civic ads (avoids error if no ad for specific badge_ids)
    ads = Worldbadges.Joins.get_ad_ids(badge_ids) |> get_ads!()
    civic_ads = list_civic_ads()
    if (mixed_ads = [civic_ads | ads] |> List.flatten()) == [],
      do: Enum.random([%Worldbadges.Posting.Ad{image: "ad1", url: "#"}, %Worldbadges.Posting.Ad{image: "ad2", url: "#"}]),
    else: Enum.random(mixed_ads)
  end

  @doc """
  Creates a ad.

  ## Examples

      iex> create_ad(%{field: value})
      {:ok, %Ad{}}

      iex> create_ad(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ad(attrs \\ %{}) do
    %Ad{}
    |> Ad.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ad.

  ## Examples

      iex> update_ad(ad, %{field: new_value})
      {:ok, %Ad{}}

      iex> update_ad(ad, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ad(%Ad{} = ad, attrs) do
    ad
    |> Ad.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Ad.

  ## Examples

      iex> delete_ad(ad)
      {:ok, %Ad{}}

      iex> delete_ad(ad)
      {:error, %Ecto.Changeset{}}

  """
  # def delete_ad(%Ad{} = ad) do
  #   Repo.delete(ad)
  # end

  @doc """
  Deletes a Ad.

  ## Examples

      iex> delete_ad(ad)
      {:ok, %Ad{}}

      iex> delete_ad(ad)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ad(ad_name, persona_id) do
    from(a in Ad, where: a.name == ^ad_name and a.persona_id == ^persona_id)
    |> Repo.delete_all
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ad changes.

  ## Examples

      iex> change_ad(ad)
      %Ecto.Changeset{source: %Ad{}}

  """
  def change_ad(%Ad{} = ad) do
    Ad.changeset(ad, %{})
  end

  alias Worldbadges.Posting.CivicAd

  @doc """
  Returns the list of civic_ads.

  ## Examples

      iex> list_civic_ads()
      [%Ad{}, ...]

  """
  def list_civic_ads do
    from(c in CivicAd, where: not ilike(c.status, "pending%"))
    |> Repo.all()
  end

  @doc """
  TODO
  Gets a single civic_ad.

  Raises `Ecto.NoResultsError` if the CivicAd does not exist.

  ## Examples

      iex> get_civic_ad!(123)
      %Ad{}

      iex> get_civic_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_civic_ads!(ids) do
    from(a in CivicAd, where: a.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Gets a single civic_ad.

  Raises `Ecto.NoResultsError` if the CivicAd does not exist.

  ## Examples

      iex> get_civic_ad!(123)
      %Ad{}

      iex> get_civic_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_civic_ad!(id), do: Repo.get!(CivicAd, id)

  @doc """
  TODO
  Gets a single civic_ad.

  Raises `Ecto.NoResultsError` if the CivicAd does not exist.

  ## Examples

      iex> get_civic_ad!(123)
      %Ad{}

      iex> get_civic_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_civic_ad(name, persona_id), do: Repo.get_by(CivicAd, name: name, persona_id: persona_id)

  @doc """
  TODO
  Gets a single civic_ad.

  Raises `Ecto.NoResultsError` if the CivicAd does not exist.

  ## Examples

      iex> get_civic_ad!(123)
      %Ad{}

      iex> get_civic_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_civic_ad!(name, persona_id), do: Repo.get_by!(CivicAd, name: name, persona_id: persona_id)

  @doc """
  TODO Update implementation to make really random
  Gets a random civic_ad.

  Raises `Ecto.NoResultsError` if the CivicAd does not exist.

  ## Examples

      iex> get_civic_ad!(123)
      %Ad{}

      iex> get_civic_ad!(456)
      ** (Ecto.NoResultsError)

  """
  def get_random_civic_ad(badge_ids) do
    # Worldbadges.Joins.get_ad_ids(badge_ids)
    # |> get_ads!()
    # |> Enum.random()
  end

  @doc """
  Creates a civic_ad.

  ## Examples

      iex> create_civic_ad(%{field: value})
      {:ok, %CivicAd{}}

      iex> create_civic_ad(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_civic_ad(attrs \\ %{}) do
    %CivicAd{}
    |> CivicAd.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a civic_ad.

  ## Examples

      iex> update_civic_ad(ad, %{field: new_value})
      {:ok, %CivicAd{}}

      iex> update_civic_ad(civic_ad, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_civic_ad(%CivicAd{} = civic_ad, attrs) do
    civic_ad
    |> CivicAd.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CivicAd.

  ## Examples

      iex> delete_civic_ad(civic_ad)
      {:ok, %CivicAd{}}

      iex> delete_civic_ad(civic_ad)
      {:error, %Ecto.Changeset{}}

  """
  # def delete_civic_ad(%CivicAd{} = civic_ad) do
  #   Repo.delete(civic_ad)
  # end

  @doc """
  Deletes a CivicAd.

  ## Examples

      iex> delete_civic_ad(civic_ad)
      {:ok, %CivicAd{}}

      iex> delete_civic_ad(civic_ad)
      {:error, %Ecto.Changeset{}}

  """
  def delete_civic_ad(ad_name, persona_id) do
    from(c in CivicAd, where: c.id == ^ad_name and c.persona_id == ^persona_id)
    |> Repo.delete_all
  end



  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ad changes.

  ## Examples

      iex> change_ad(ad)
      %Ecto.Changeset{source: %Ad{}}

  """
  def change_civic_ad(%CivicAd{} = civic_ad) do
    CivicAd.changeset(civic_ad, %{})
  end

  alias Worldbadges.Posting.Article

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Repo.all(Article)
  end

  @doc """
  TODO
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def articles_for_pages(page_ids, limit, offset) do
    # Repo.all(Article)
    from(a in Article, where: a.page_id in ^page_ids, order_by: [desc: :inserted_at], limit: ^limit, offset: ^offset)
    |> Repo.all()
  end

  @doc """
  TODO
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def articles_for_persona(persona, false, limit, offset) do
    page_ids = Worldbadges.Groups.subdpages_group(persona.id).ids

    from(a in Article,
      where: a.page_id in ^page_ids,
      order_by: [desc: :inserted_at],
      limit: ^limit,
      offset: ^offset
    ) |> Repo.all()
  end

  def articles_for_persona(persona, true, limit, offset) do
    persona = persona |> Repo.preload(:contact)
    contact_ids = contact_ids(persona.contact)
    page_ids = Worldbadges.Groups.subdpages_group(persona.id).ids

    from(a in Article,
      where: a.page_id in ^page_ids or a.persona_id in ^contact_ids,
      order_by: [desc: :inserted_at],
      limit: ^limit,
      offset: ^offset
    ) |> Repo.all()
  end

  # TODO: documentation
  def persona_articles(persona_id, public, limit, offset) when public == true do
    from(a in Article, where: is_nil(a.page_id) and is_nil(a.visibility) and a.persona_id == ^persona_id, limit: ^limit, offset: ^offset, order_by: [desc: :inserted_at])
    |> Repo.all()
  end

  def persona_articles(persona_id, public, limit, offset) do
    from(a in Article, where: is_nil(a.page_id) and a.persona_id == ^persona_id, limit: ^limit, offset: ^offset, order_by: [desc: :inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id)

  def get_page_article(article_id, page_id) do
    Repo.get_by(Article, id: article_id, page_id: page_id)
  end

  def article_approvals(persona_id, left_at) do
    from(a in ArticleApproval, where: a.persona_id == ^persona_id, where: a.updated_at > ^left_at)
    |> Repo.all()
  end

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{source: %Article{}}

  """
  def change_article(%Article{} = article) do
    Article.changeset(article, %{})
  end

  alias Worldbadges.Posting.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  def get_last_messages(recipient_id, sender_id, limit, offset) do
    from(m in Message, where: (m.persona_id == ^sender_id and m.recipient_id == ^recipient_id) or (m.recipient_id == ^sender_id and m.persona_id == ^recipient_id),
    limit: ^limit, offset: ^offset, order_by: [desc: :inserted_at])
    |> Repo.all()
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end

  alias Worldbadges.Posting.PendingArticle

  @doc """
  Returns the list of pending_articles.

  ## Examples

      iex> list_pending_articles()
      [%PendingArticle{}, ...]

  """
  def list_pending_articles do
    Repo.all(PendingArticle)
  end

  @doc """
  Gets a single pending_article.

  Raises `Ecto.NoResultsError` if the Pending article does not exist.

  ## Examples

      iex> get_pending_article!(123)
      %PendingArticle{}

      iex> get_pending_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pending_article!(id), do: Repo.get!(PendingArticle, id)

  @doc """
  Creates a pending_article.

  ## Examples

      iex> create_pending_article(%{field: value})
      {:ok, %PendingArticle{}}

      iex> create_pending_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pending_article(attrs \\ %{}) do
    %PendingArticle{}
    |> PendingArticle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pending_article.

  ## Examples

      iex> update_pending_article(pending_article, %{field: new_value})
      {:ok, %PendingArticle{}}

      iex> update_pending_article(pending_article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pending_article(%PendingArticle{} = pending_article, attrs) do
    pending_article
    |> PendingArticle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PendingArticle.

  ## Examples

      iex> delete_pending_article(pending_article)
      {:ok, %PendingArticle{}}

      iex> delete_pending_article(pending_article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pending_article(%PendingArticle{} = pending_article) do
    Repo.delete(pending_article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pending_article changes.

  ## Examples

      iex> change_pending_article(pending_article)
      %Ecto.Changeset{source: %PendingArticle{}}

  """
  def change_pending_article(%PendingArticle{} = pending_article) do
    PendingArticle.changeset(pending_article, %{})
  end
end
