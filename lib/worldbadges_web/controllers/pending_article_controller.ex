defmodule WorldbadgesWeb.PendingArticleController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.Posting
  alias Worldbadges.Posting.PendingArticle

  def index(conn, _params) do
    pending_articles = Posting.list_pending_articles()
    render(conn, "index.html", pending_articles: pending_articles)
  end

  def new(conn, _params) do
    changeset = Posting.change_pending_article(%PendingArticle{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pending_article" => pending_article_params}) do
    case Posting.create_pending_article(pending_article_params) do
      {:ok, pending_article} ->
        conn
        |> put_flash(:info, "Pending article created successfully.")
        |> redirect(to: pending_article_path(conn, :show, pending_article))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    pending_article = Posting.get_pending_article!(id)
    render(conn, "show.html", pending_article: pending_article)
  end

  def edit(conn, %{"id" => id}) do
    pending_article = Posting.get_pending_article!(id)
    changeset = Posting.change_pending_article(pending_article)
    render(conn, "edit.html", pending_article: pending_article, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pending_article" => pending_article_params}) do
    pending_article = Posting.get_pending_article!(id)

    case Posting.update_pending_article(pending_article, pending_article_params) do
      {:ok, pending_article} ->
        conn
        |> put_flash(:info, "Pending article updated successfully.")
        |> redirect(to: pending_article_path(conn, :show, pending_article))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pending_article: pending_article, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    pending_article = Posting.get_pending_article!(id)
    {:ok, _pending_article} = Posting.delete_pending_article(pending_article)

    conn
    |> put_flash(:info, "Pending article deleted successfully.")
    |> redirect(to: pending_article_path(conn, :index))
  end
end
