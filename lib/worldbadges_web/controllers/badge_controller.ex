defmodule WorldbadgesWeb.BadgeController do
  use WorldbadgesWeb, :controller

  plug :put_layout, "settings.html"

  alias Worldbadges.{Features, Repo}
  alias Worldbadges.Features.Badge

  import WorldbadgesWeb.Shared, only: [allocate_name: 0, base_image: 1, get_persona: 1, image_for_badge: 1, unparse_name: 1, upload_encoded_data: 3, upload_image: 3]

  def create(conn, %{"badge" => params}) do
    persona = get_persona(conn)
    badge_params = params
      |> Map.put("persona_id", persona.id)
      |> Map.put("image", allocate_name())

    case Features.create_badge(badge_params) do
      {:ok, badge} ->
        input = badge_params["canvascontent"]
        upload_encoded_data(:badge, input, badge.image<>".jpg")

        send_resp(conn, 200, "")
      {:error, %Ecto.Changeset{} = changeset} ->
        errors = Enum.map(changeset.errors, fn({field, error}) ->
          "#{field} #{elem(error, 0)}" |> String.capitalize()
        end)
        |> Enum.join("\n")

        send_resp(conn, 400, errors)
    end
  end

  def delete(conn, %{"id" => id}) do
    badge = Features.get_badge!(id)
    {:ok, _badge} = Features.delete_badge(badge)

    conn
    |> put_flash(:info, "Badge deleted successfully.")
    |> redirect(to: badge_path(conn, :index))
  end

  def edit(conn, %{"name" => name}) do
    persona = get_persona(conn)
    name = unparse_name(name)
    badge = Features.get_badge(name, persona.id)
    changeset = Features.change_badge(badge)

    render(conn, "edit.html", badge: badge, changeset: changeset, pages: Worldbadges.Groups.pages_for(persona.id))
  end

  def index(conn, _params) do
    badges = Features.list_badges()
    render(conn, "index.html", badges: badges)
  end

  def new(conn, params) do
    require IEx
    IEx.pry()
    persona = get_persona(conn)
    changeset = Features.change_badge(%Badge{})
    render(conn, "new.html", changeset: changeset, badge: %Badge{image: params["image"]}, pages: Worldbadges.Groups.pages_for(persona.id))
  end

  def show(conn, %{"id" => id}) do
    badge = Features.get_badge!(id)
    render(conn, "show.html", badge: badge)
  end

  def update(conn, %{"name" => name, "badge" => badge_params}) do
    name = unparse_name(name)
    badge = Features.get_badge(name, get_persona(conn).id)

    # TODO: update redirects to send_resp()
    case Features.update_badge(badge, badge_params) do
      {:ok, badge} ->
        input = badge_params["canvascontent"]
        upload_encoded_data(:badge, input, badge.image<>".jpg")

        send_resp(conn, 200, "")
      {:error, %Ecto.Changeset{} = changeset} ->
        errors = Enum.map(changeset.errors, fn({field, error}) ->
          "#{field} #{elem(error, 0)}" |> String.capitalize()
        end)
        |> Enum.join("\n")

        send_resp(conn, 400, errors)
    end
  end

  defp update_page(badge) do
    if page = badge |> Repo.preload(:page) |> Map.fetch!(:page) do
      Worldbadges.Groups.update_page(page, %{image: badge.image})
    end
  end
end
