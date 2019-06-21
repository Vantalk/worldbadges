defmodule WorldbadgesWeb.SharedController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.{
    Accounts,
    Features,
    Groups,
    Information,
    Information.Case,
    Joins,
    Operations,
    Posting,
    Repo,
    Settings
  }

  alias WorldbadgesWeb.Shared

  plug :put_layout, "settings.html"

  @ad_permitted_attrs ["id, name, image, url, targets, status"]
  @badge_permitted_attrs ["id, name"]
  @civic_ad_permitted_attrs ["id, name, image, url, status"]
  @page_permitted_attrs ["id, photo, name, free_access, public_view, roles, parent_page_id"]
  # @page_group_permitted_attrs ["id, name"]
  @persona_group_permitted_attrs ["id, name"]

  # def creation_panel(conn, params) do
  #   persona         = conn.assigns[:current_persona]
  #   ad_changeset    = Posting.change_ad(%Posting.Ad{})
  #   badge_changeset = Features.change_badge(%Features.Badge{})
  #   page_changeset  = Groups.change_page(%Groups.Page{})
  #   badges          = Groups.my_badges(persona.id)
  #   general_badges  = Groups.general_badges()
  #   persona_badges  = Groups.persona_badges(persona.id)
  #   pages           = Groups.my_pages(persona.id)
  #   contacts        = Groups.contacts_for(persona.id)
  #
  #   render(conn, "creation_panel.html",
  #     ad_changeset: ad_changeset,
  #     badge_changeset: badge_changeset,
  #     page_changeset:  page_changeset,
  #     badges: badges,
  #     general_badges: general_badges,
  #     persona_badges: persona_badges,
  #     pages: pages,
  #     contacts: contacts,
  #     image: params["image"],
  #   )
  # end

  def create_case(conn, %{"case" => params, "back" => back}) do
    persona_id = if conn.assigns[:current_persona], do: conn.assigns[:current_persona].id
    case_params = Map.put(params, "persona_id", persona_id)

    case Information.create_case(case_params) do
      {:ok, obj} ->
        conn = put_flash(conn, :info, "Case submitted")
        case back do
          "new_user" -> redirect(conn, to: user_path(conn, :new))
          "settings" -> redirect(conn, to: page_path(conn, :settings))
          "help"     -> redirect(conn, to: shared_path(conn, :help))
        end
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "help_form.html", changeset: changeset)
    end
  end

  def create_group(conn, %{"group" => params}) do
    persona = conn.assigns[:current_persona]
    ids  = params["ids"] |> String.split(",")
    name = params["name"] |> String.trim()

    errors = if length(ids) < 2, do: ["Must select at least two group items"], else: []
    errors = if not String.match?(name, ~r/^[a-zA-Z \d-]{2,30}$/), do: ["Name can only contain spaces, numbers, letters and hiphens and must be at least 2 characters long" | errors], else: errors
    # errors = if errors == [] && Groups.get_page_group(persona.id, name), do: ["You already have a group with this name" | errors], else: errors

    if errors != [] do
      send_resp(conn, 400, Enum.join(errors, "\n"))
    else
      # {atom, response} =
      #   case params["type"] do
      #     # "badges"   -> Groups.create_badge_group(%{persona_id: persona.id, name: params["name"], ids: ids})
      #     "pages"    -> Groups.create_page_group(%{persona_id: persona.id, name: params["name"], ids: ids})
      #     "contacts" -> Groups.create_persona_group(%{persona_id: persona.id, name: params["name"], ids: ids})
      #   end

      # if atom == :ok do
      #   send_resp(conn, 200, "")
      # else
      case Groups.create_persona_group(%{persona_id: persona.id, name: params["name"], ids: ids}) do
        {:ok, persona_group} -> send_resp(conn, 200, "")
        {:error, response} ->
          errors = Enum.map(response, fn({field, error}) ->
            "#{field} #{elem(error, 0)}" |> String.capitalize()
          end)
          |> Enum.join("\n")

          send_resp(conn, 400, errors)
      end
    end
  end

  def help(conn, _) do
    render(conn, "help.html", layout: {WorldbadgesWeb.LayoutView, "app.html"})
  end

  def help_form(conn, %{"back" => back}) do
    changeset = Information.change_case(%Case{})
    render(conn, "help_form.html", back: back, changeset: changeset, layout: {WorldbadgesWeb.LayoutView, "app.html"})
  end

  def news(conn, _) do
    render(conn, "news.html", layout: {WorldbadgesWeb.LayoutView, "app.html"})
  end

  def access_settings(conn, _) do
    persona_changeset = conn.assigns[:current_persona] |> Accounts.change_persona()

    render(conn, "access_settings.html", persona_changeset: persona_changeset)
  end

  def notifications_settings(conn, _) do
    persona = conn.assigns[:current_persona] |> Repo.preload(:privacy)
    persona_changeset = persona |> Accounts.change_persona()
    connected_notifications? = persona.privacy.settings["notifications"] == "connected"

    render(conn, "notifications_settings.html", connected_notifications?: connected_notifications?, persona_changeset: persona_changeset)
  end

  def get_list(conn, %{"type" => type}) do
    persona = conn.assigns[:current_persona]

    list = case type do
      "ad" ->
        image_path = &Shared.image_for_ad(&1);
        persona = persona |> Repo.preload(:ads) |> Repo.preload(:civic_ads);
        grouped_records_to_string(%{"Ads" => persona.ads, "Civic ads" => persona.civic_ads}, image_path)
      "badge" ->
        image_path = &Shared.image_for_badge(&1);
        persona = persona |> Repo.preload(:badges);
        records_to_string(persona.badges, type, image_path)
      "page" ->
        image_path = &Shared.image_for_page(&1);
        Groups.my_pages(persona.id) |> records_to_string(type, image_path)
      "group" ->
        # [page_groups, persona_groups] = Groups.for(persona.id);
        # grouped_records_to_string(%{"Page groups" => page_groups, "User groups" => persona_groups}, nil)
        image_path = &Shared.image_for_page(&1);
        Groups.persona_groups_for(persona.id) |> records_to_string(type, nil)
    end

    send_resp(conn, 200, list)
  end

  def edit(conn, params) do
    persona = conn.assigns[:current_persona]
    id = String.to_integer(params["id"])

    list = case params["type"] do
      "ad" -> Ecto.Adapters.SQL.query!(Repo, "SELECT #{@ad_permitted_attrs} FROM ads WHERE id = #{id} AND persona_id = #{persona.id}")
      "badge" -> Ecto.Adapters.SQL.query!(Repo, "SELECT #{@badge_permitted_attrs} FROM badges WHERE id = #{id} AND persona_id = #{persona.id}")
      "civic_ad" -> Ecto.Adapters.SQL.query!(Repo, "SELECT #{@civic_ad_permitted_attrs} FROM civic_ads WHERE id = #{id} AND persona_id = #{persona.id}")
      "page" -> Ecto.Adapters.SQL.query!(Repo, "SELECT #{@page_permitted_attrs} FROM pages WHERE id = #{id} AND persona_id = #{persona.id}")
      # "page_group" -> Ecto.Adapters.SQL.query!(Repo, "SELECT #{@page_group_permitted_attrs} FROM page_groups WHERE id = #{id} AND persona_id = #{persona.id}")
      "persona_group" -> Ecto.Adapters.SQL.query!(Repo, "SELECT #{@persona_group_permitted_attrs} FROM persona_groups WHERE id = #{id} AND persona_id = #{persona.id}")
    end

    rows = Enum.at(list.rows, 0)
    x = for {c, index} <- Stream.with_index(list.columns), into: [], do: [c, Enum.at(rows, index)]
    {:ok, a} = x |> JSON.encode()
    send_resp(conn, 200, a)

    # if object.persona_id == id do
    #   object
    #   send_resp(conn, 200, list)
    # else
    #   send_resp(conn, 400, "")
    # end
  end

  def delete(conn, %{"type" => type, "name" => name}) do
    persona = conn.assigns[:current_persona]

    # NOTE: TEMPORARY DIRECT DELETE. Should probably use the create_delete_task below to delay instead?

    object = case type do
      "ads"          -> Posting.delete_ad(name, persona.id)
      "badges"       -> Features.delete_badge(name, persona.id)
      "pages"        -> Groups.delete_page(name, persona.id)
      "civic_ads"    -> Posting.delete_civic_ad(name, persona.id)
      # "page_groups"  -> Groups.delete_page_group(name, persona.id)
      "persona_groups"  -> Groups.delete_persona_group(name, persona.id)
    end

    # object = case type do
    #   "ad"          -> Posting.get_ad!(id)
    #   "badge"       -> Features.get_badge!(id)
    #   "page"        -> Groups.get_page!(id)
    #   "civic_ad"    -> Posting.get_civic_ad!(id)
    #   "page_group"  -> Groups.get_page_group!(id)
    #   "persona_group"  -> Groups.get_persona_group!(id)
    # end
    #
    # if object && object.persona_id == persona.id do
    #   Worldbadges.Operations.create_delete_task(%{type: type, obj_id: id})
    #   # TODO: flag page marked for deletion
    #   # TODO: create cron Groups.delete_page(page); delete notifications or just 404?
    #   # TODO: can't delete ad without deleting join relation with badge (used to get all ads related to a badge)
    #
    #   # conn
    #   # |> put_flash(:info, "Queued for deletion.")
    #   # |> redirect(to: page_path(conn, :index))
    #   send_resp(conn, 200, "Queued for deletion.")
    # else
    #   send_resp(conn, 400, "")
    # end
  end

  defp grouped_records_to_string(grouped_records, image_path) do
    "<div class='row'>" <>
    Enum.reduce(grouped_records, "", fn({group_name,records}, acc) ->
      type = group_name |> String.downcase() |> String.replace(" ", "_")
      acc <> "<div class='col-sm-3'><b>#{group_name}</b>" <> records_to_string(records, type, image_path) <> "</div>"
    end) <>
    "</div>"
  end

  defp records_to_string(items, type, image_path) do
    Enum.map(items, fn(item) ->
    "<div data-name='#{item.name}' data-type='#{type}'>"<>
    image_string(type, item, image_path) <>
    show_string(type) <>
    "<a class='fa fa-pencil' aria-hidden='true' onclick='edit(this)'></a> "<>
    "<a class='fa fa-times' aria-hidden='true' onclick='remove(this)'></a>"<>
    "</div>" end) |> Enum.join("")
    # Enum.reduce(items, %{}, fn(item, acc) -> Map.put(acc, item.name, item.id) end)
  end

  defp show_string(type) do
    if type != "badge", do: "<a class='fa fa-eye' aria-hidden='true' onclick='show(this)'></a> ",
    else: ""
  end

  defp image_string(type, item, image_path) do
    # if type in ~w(page_groups persona_groups), do: "#{item.name} ",
    if type == "persona_groups", do: "#{item.name} ",
    else: "<img src=#{image_path.(item)} class='small-badge'>#{item.name} "
  end
end
