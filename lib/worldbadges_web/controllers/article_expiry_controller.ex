defmodule WorldbadgesWeb.ArticleExpiryController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.Information
  alias Worldbadges.Information.ArticleExpiry

  # def index(conn, _params) do
  #   article_expiry = Information.list_article_expiry()
  #   render(conn, "index.html", article_expiry: article_expiry)
  # end
  #
  # def new(conn, _params) do
  #   changeset = Information.change_article_expiry(%ArticleExpiry{})
  #   render(conn, "new.html", changeset: changeset)
  # end
  #
  # def create(conn, %{"article_expiry" => article_expiry_params}) do
  #   case Information.create_article_expiry(article_expiry_params) do
  #     {:ok, article_expiry} ->
  #       conn
  #       |> put_flash(:info, "Article expiry created successfully.")
  #       |> redirect(to: article_expiry_path(conn, :show, article_expiry))
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "new.html", changeset: changeset)
  #   end
  # end
  #
  # def show(conn, %{"id" => id}) do
  #   article_expiry = Information.get_article_expiry!(id)
  #   render(conn, "show.html", article_expiry: article_expiry)
  # end
  #
  # def edit(conn, %{"id" => id}) do
  #   article_expiry = Information.get_article_expiry!(id)
  #   changeset = Information.change_article_expiry(article_expiry)
  #   render(conn, "edit.html", article_expiry: article_expiry, changeset: changeset)
  # end
  #
  # def update(conn, %{"id" => id, "article_expiry" => article_expiry_params}) do
  #   article_expiry = Information.get_article_expiry!(id)
  #
  #   case Information.update_article_expiry(article_expiry, article_expiry_params) do
  #     {:ok, article_expiry} ->
  #       conn
  #       |> put_flash(:info, "Article expiry updated successfully.")
  #       |> redirect(to: article_expiry_path(conn, :show, article_expiry))
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", article_expiry: article_expiry, changeset: changeset)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   article_expiry = Information.get_article_expiry!(id)
  #   {:ok, _article_expiry} = Information.delete_article_expiry(article_expiry)
  #
  #   conn
  #   |> put_flash(:info, "Article expiry deleted successfully.")
  #   |> redirect(to: article_expiry_path(conn, :index))
  # end
end
