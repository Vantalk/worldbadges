defmodule Worldbadges.Features do
  @moduledoc """
  The Features context.
  """

  import Ecto.Query, warn: false
  alias Worldbadges.Repo

  alias Worldbadges.Features.Badge

  @doc """
  Returns the list of badges.

  ## Examples

      iex> list_badges()
      [%Badge{}, ...]

  """
  def list_badges do
    Repo.all(Badge)
  end

  @doc """
  TODO
  Returns the list of badges.

  ## Examples

      iex> list_badges()
      [%Badge{}, ...]

  """
  def get_badges(ids) do
    from(b in Badge, where: b.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Gets a single badge.

  Raises `Ecto.NoResultsError` if the Badge does not exist.

  ## Examples

      iex> get_badge!(123)
      %Badge{}

      iex> get_badge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_badge!(id), do: Repo.get!(Badge, id)

  # TODO: documentation
  def get_badge(name, persona_id), do: Repo.get_by(Badge, name: name, persona_id: persona_id)

  @doc """
  Creates a badge.

  ## Examples

      iex> create_badge(%{field: value})
      {:ok, %Badge{}}

      iex> create_badge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_badge(attrs \\ %{}) do
    %Badge{}
    |> Badge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a badge.

  ## Examples

      iex> update_badge(badge, %{field: new_value})
      {:ok, %Badge{}}

      iex> update_badge(badge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_badge(%Badge{} = badge, attrs) do
    badge
    |> Badge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  TODO
  Deletes a Badge.

  ## Examples

      iex> delete_badge(badge)
      {:ok, %Badge{}}

      iex> delete_badge(badge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_badge(badge_name, persona_id) do
    from(b in Badge, where: b.name == ^badge_name and b.persona_id == ^persona_id)
    |> Repo.delete_all
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking badge changes.

  ## Examples

      iex> change_badge(badge)
      %Ecto.Changeset{source: %Badge{}}

  """
  def change_badge(%Badge{} = badge) do
    Badge.changeset(badge, %{})
  end

  alias Worldbadges.Features.Recognition

  @doc """
  Returns the list of recognitions.

  ## Examples

      iex> list_recognitions()
      [%Recognition{}, ...]

  """
  def list_recognitions do
    Repo.all(Recognition)
  end

  @doc """
  Gets a single recognition.

  Raises `Ecto.NoResultsError` if the Recognition does not exist.

  ## Examples

      iex> get_recognition!(123)
      %Recognition{}

      iex> get_recognition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_recognition!(id), do: Repo.get!(Recognition, id)

  # TODO: doc
  def get_recognition(article_id, persona_id, receiver_id) do
    Repo.get_by(Recognition, article_id: article_id, persona_id: persona_id, receiver_id: receiver_id)
  end


  @doc """
  Creates a recognition.

  ## Examples

      iex> create_recognition(%{field: value})
      {:ok, %Recognition{}}

      iex> create_recognition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recognition(attrs \\ %{}) do
    %Recognition{}
    |> Recognition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a recognition.

  ## Examples

      iex> update_recognition(recognition, %{field: new_value})
      {:ok, %Recognition{}}

      iex> update_recognition(recognition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recognition(%Recognition{} = recognition, attrs) do
    recognition
    |> Recognition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Recognition.

  ## Examples

      iex> delete_recognition(recognition)
      {:ok, %Recognition{}}

      iex> delete_recognition(recognition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recognition(%Recognition{} = recognition) do
    Repo.delete(recognition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recognition changes.

  ## Examples

      iex> change_recognition(recognition)
      %Ecto.Changeset{source: %Recognition{}}

  """
  def change_recognition(%Recognition{} = recognition) do
    Recognition.changeset(recognition, %{})
  end

  alias Worldbadges.Features.RecognitionTotal

  @doc """
  Returns the list of recognition_totals.

  ## Examples

      iex> list_recognition_totals()
      [%RecognitionTotal{}, ...]

  """
  def list_recognition_totals do
    Repo.all(RecognitionTotal)
  end

  @doc """
  Gets a single recognition_total.

  Raises `Ecto.NoResultsError` if the Recognition total does not exist.

  ## Examples

      iex> get_recognition_total!(123)
      %RecognitionTotal{}

      iex> get_recognition_total!(456)
      ** (Ecto.NoResultsError)

  """
  # def get_recognition_total!(id), do: Repo.get!(RecognitionTotal, id)

  # TODO: doc
  def get_recognition_total!(persona_id), do: Repo.get_by!(RecognitionTotal, persona_id: persona_id)

  @doc """
  Creates a recognition_total.

  ## Examples

      iex> create_recognition_total(%{field: value})
      {:ok, %RecognitionTotal{}}

      iex> create_recognition_total(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recognition_total(attrs \\ %{}) do
    %RecognitionTotal{}
    |> RecognitionTotal.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a recognition_total.

  ## Examples

      iex> update_recognition_total(recognition_total, %{field: new_value})
      {:ok, %RecognitionTotal{}}

      iex> update_recognition_total(recognition_total, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recognition_total(%RecognitionTotal{} = recognition_total, attrs) do
    recognition_total
    |> RecognitionTotal.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RecognitionTotal.

  ## Examples

      iex> delete_recognition_total(recognition_total)
      {:ok, %RecognitionTotal{}}

      iex> delete_recognition_total(recognition_total)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recognition_total(recognition_total_id) do
    from(p in RecognitionTotal, where: p.id == ^recognition_total_id) |> Repo.delete_all
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recognition_total changes.

  ## Examples

      iex> change_recognition_total(recognition_total)
      %Ecto.Changeset{source: %RecognitionTotal{}}

  """
  def change_recognition_total(%RecognitionTotal{} = recognition_total) do
    RecognitionTotal.changeset(recognition_total, %{})
  end

  alias Worldbadges.Features.CommentApproval

  @doc """
  Returns the list of comment_approvals.

  ## Examples

      iex> list_comment_approvals()
      [%CommentApproval{}, ...]

  """
  def list_comment_approvals do
    Repo.all(CommentApproval)
  end

  @doc """
  TODO
  Returns the list of comment_approvals.

  ## Examples

      iex> list_comment_approvals()
      [%CommentApproval{}, ...]

  """
  def comment_approvals(persona_id, left_at) do
    from(c in CommentApproval, where: c.persona_id == ^persona_id, where: c.updated_at > ^left_at)
    |> Repo.all()
  end

  @doc """
  Gets a single comment_approval.

  Raises `Ecto.NoResultsError` if the Comment approval does not exist.

  ## Examples

      iex> get_comment_approval!(123)
      %CommentApproval{}

      iex> get_comment_approval!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment_approval!(id), do: Repo.get!(CommentApproval, id)

  @doc """
  Creates a comment_approval.

  ## Examples

      iex> create_comment_approval(%{field: value})
      {:ok, %CommentApproval{}}

      iex> create_comment_approval(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment_approval(attrs \\ %{}) do
    %CommentApproval{}
    |> CommentApproval.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment_approval.

  ## Examples

      iex> update_comment_approval(comment_approval, %{field: new_value})
      {:ok, %CommentApproval{}}

      iex> update_comment_approval(comment_approval, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment_approval(%CommentApproval{} = comment_approval, attrs) do
    comment_approval
    |> CommentApproval.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CommentApproval.

  ## Examples

      iex> delete_comment_approval(comment_approval)
      {:ok, %CommentApproval{}}

      iex> delete_comment_approval(comment_approval)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment_approval(%CommentApproval{} = comment_approval) do
    Repo.delete(comment_approval)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment_approval changes.

  ## Examples

      iex> change_comment_approval(comment_approval)
      %Ecto.Changeset{source: %CommentApproval{}}

  """
  def change_comment_approval(%CommentApproval{} = comment_approval) do
    CommentApproval.changeset(comment_approval, %{})
  end

  alias Worldbadges.Features.ArticleApproval

  @doc """
  Returns the list of article_approvals.

  ## Examples

      iex> list_article_approvals()
      [%ArticleApproval{}, ...]

  """
  def list_article_approvals do
    Repo.all(ArticleApproval)
  end

  @doc """
  TODO
  Returns the list of comment_approvals.

  ## Examples

      iex> list_comment_approvals()
      [%CommentApproval{}, ...]

  """
  def article_approvals(persona_id, left_at) do
    from(a in ArticleApproval, where: a.persona_id == ^persona_id and a.updated_at > ^left_at)
    |> Repo.all()
  end

  @doc """
  Gets a single article_approval.

  Raises `Ecto.NoResultsError` if the Article approval does not exist.

  ## Examples

      iex> get_article_approval!(123)
      %ArticleApproval{}

      iex> get_article_approval!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article_approval!(id), do: Repo.get!(ArticleApproval, id)

  @doc """
  Creates a article_approval.

  ## Examples

      iex> create_article_approval(%{field: value})
      {:ok, %ArticleApproval{}}

      iex> create_article_approval(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article_approval(attrs \\ %{}) do
    %ArticleApproval{}
    |> ArticleApproval.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article_approval.

  ## Examples

      iex> update_article_approval(article_approval, %{field: new_value})
      {:ok, %ArticleApproval{}}

      iex> update_article_approval(article_approval, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article_approval(%ArticleApproval{} = article_approval, attrs) do
    article_approval
    |> ArticleApproval.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ArticleApproval.

  ## Examples

      iex> delete_article_approval(article_approval)
      {:ok, %ArticleApproval{}}

      iex> delete_article_approval(article_approval)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article_approval(%ArticleApproval{} = article_approval) do
    Repo.delete(article_approval)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article_approval changes.

  ## Examples

      iex> change_article_approval(article_approval)
      %Ecto.Changeset{source: %ArticleApproval{}}

  """
  def change_article_approval(%ArticleApproval{} = article_approval) do
    ArticleApproval.changeset(article_approval, %{})
  end
end
