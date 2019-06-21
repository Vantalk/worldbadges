defmodule WorldbadgesWeb.PrivacyController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.Settings
  alias Worldbadges.Settings.Privacy

  def index(conn, _params) do
    privacy = Settings.list_privacy()
    render(conn, "index.html", privacy: privacy)
  end

  def new(conn, _params) do
    changeset = Settings.change_privacy(%Privacy{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"privacy" => privacy_params}) do
    case Settings.create_privacy(privacy_params) do
      {:ok, privacy} ->
        conn
        |> put_flash(:info, "Privacy created successfully.")
        |> redirect(to: privacy_path(conn, :show, privacy))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    privacy = Settings.get_privacy!(id)
    render(conn, "show.html", privacy: privacy)
  end

  def edit(conn, %{"id" => id}) do
    privacy = Settings.get_privacy!(id)
    changeset = Settings.change_privacy(privacy)
    render(conn, "edit.html", privacy: privacy, changeset: changeset)
  end

  def update(conn, %{"id" => id, "privacy" => privacy_params}) do
    privacy = Settings.get_privacy!(id)

    case Settings.update_privacy(privacy, privacy_params) do
      {:ok, privacy} ->
        conn
        |> put_flash(:info, "Privacy updated successfully.")
        |> redirect(to: privacy_path(conn, :show, privacy))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", privacy: privacy, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    privacy = Settings.get_privacy!(id)
    {:ok, _privacy} = Settings.delete_privacy(privacy)

    conn
    |> put_flash(:info, "Privacy deleted successfully.")
    |> redirect(to: privacy_path(conn, :index))
  end
end
