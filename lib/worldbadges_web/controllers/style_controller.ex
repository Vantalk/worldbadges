defmodule WorldbadgesWeb.StyleController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.Settings
  alias Worldbadges.Settings.Style

  def index(conn, _params) do
    styles = Settings.list_styles()
    render(conn, "index.html", styles: styles)
  end

  def new(conn, _params) do
    changeset = Settings.change_style(%Style{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"style" => style_params}) do
    case Settings.create_style(style_params) do
      {:ok, style} ->
        conn
        |> put_flash(:info, "Style created successfully.")
        |> redirect(to: style_path(conn, :show, style))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    style = Settings.get_style!(id)
    render(conn, "show.html", style: style)
  end

  def edit(conn, %{"id" => id}) do
    style = Settings.get_style!(id)
    changeset = Settings.change_style(style)
    render(conn, "edit.html", style: style, changeset: changeset)
  end

  def update(conn, %{"id" => id, "style" => style_params}) do
    style = Settings.get_style!(id)

    case Settings.update_style(style, style_params) do
      {:ok, style} ->
        conn
        |> put_flash(:info, "Style updated successfully.")
        |> redirect(to: style_path(conn, :show, style))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", style: style, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    style = Settings.get_style!(id)
    {:ok, _style} = Settings.delete_style(style)

    conn
    |> put_flash(:info, "Style deleted successfully.")
    |> redirect(to: style_path(conn, :index))
  end
end
