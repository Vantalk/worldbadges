defmodule WorldbadgesWeb.InterestArticleController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.Information
  alias Worldbadges.Information.InterestArticle

  def index(conn, _params) do
    interest_articles = Information.list_interest_articles()
    render(conn, "index.html", interest_articles: interest_articles)
  end

  def new(conn, _params) do
    changeset = Information.change_interest_article(%InterestArticle{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"interest_article" => interest_article_params}) do
    case Information.create_interest_article(interest_article_params) do
      {:ok, interest_article} ->
        conn
        |> put_flash(:info, "Interest article created successfully.")
        |> redirect(to: interest_article_path(conn, :show, interest_article))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    interest_article = Information.get_interest_article!(id)
    render(conn, "show.html", interest_article: interest_article)
  end

  def edit(conn, %{"id" => id}) do
    interest_article = Information.get_interest_article!(id)
    changeset = Information.change_interest_article(interest_article)
    render(conn, "edit.html", interest_article: interest_article, changeset: changeset)
  end

  def update(conn, %{"id" => id, "interest_article" => interest_article_params}) do
    interest_article = Information.get_interest_article!(id)

    case Information.update_interest_article(interest_article, interest_article_params) do
      {:ok, interest_article} ->
        conn
        |> put_flash(:info, "Interest article updated successfully.")
        |> redirect(to: interest_article_path(conn, :show, interest_article))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", interest_article: interest_article, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    interest_article = Information.get_interest_article!(id)
    {:ok, _interest_article} = Information.delete_interest_article(interest_article)

    conn
    |> put_flash(:info, "Interest article deleted successfully.")
    |> redirect(to: interest_article_path(conn, :index))
  end
end
