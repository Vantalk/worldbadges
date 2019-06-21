defmodule WorldbadgesWeb.PersonaController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.{
    Accounts,
    Accounts.Persona,
    Features,
    Groups,
    Information,
    Joins,
    Posting,
    Repo,
    Settings,
    Settings.Privacy,
    Settings.Style
  }

  alias WorldbadgesWeb.LayoutView

  # @badge_base_path_dev "assets/static/images/base/"
  # @profile_image_path_dev "assets/static/images/profiles/"

  import WorldbadgesWeb.Shared, only: [
    allocate_name: 0,
    default_limit: 0,
    default_page_limit: 0,
    get_persona: 1,
    image_for_persona: 1,
    link_for_persona: 1,
    parse_name: 1,
    upload_encoded_data: 3,
    upload_image: 3,
    unparse_name: 1
  ]

  # plug :scrub_params, "persona" when action in [:create]

  def change_persona(conn, %{"id" => id}) do
    current_persona = get_persona(conn)
    persona = Accounts.get_persona!(id)
    if persona.user_id == current_persona.user_id do

      conn = WorldbadgesWeb.Auth.logout(conn)
        |> Guardian.Plug.sign_in(persona)
        # |> assign(:current_persona, persona)

      redirect(conn, to: persona_path(conn, :edit, persona))
    else
      send_resp(conn, 404, "Invalid persona")
    end
  end

  def change_persona(conn, _) do
    current_persona = get_persona(conn)
    user_personas = Accounts.get_personas_by_user(current_persona.user_id)
    length = length(user_personas)

    persona = cond do
      length == 1 -> current_persona
      length == 2 -> (user_personas -- [current_persona]) |> Enum.at(0)
      length == 3 ->
        index = Enum.find_index(user_personas, &(&1.id == current_persona.id))
        index = if index == 2, do: 0, else: index + 1
        Enum.at(user_personas, index)
      true -> current_persona
    end

    conn = if persona,
      do: WorldbadgesWeb.Auth.logout(conn) |> Guardian.Plug.sign_in(persona),
    else: conn

    redirect(conn, to: page_path(conn, :index))
  end

  # def edit(conn, %{"id" => id}) do
  #   persona = get_persona(conn)
  #   badges = current_persona.id |> Groups.subdpages_group()
  #
  #   render(conn, "edit.html", pages: [], layout: {LayoutView, "settings.html"})
  # end

  def edit(conn, params) do
    persona = get_persona(conn)
    personas = Accounts.get_personas_by_user(persona.user_id, [])
    generalbadges_ids =  Groups.general_badges_group().ids
    general_badges = Features.get_badges(generalbadges_ids)
    data = edit_data(persona, params)
    # my_gen_badge_ids = Enum.filter(data["badges"].ids, fn(id) -> id in generalbadges_ids end)
    # my_gen_badge_ids = if is_list(my_gen_badge_ids), do: my_gen_badge_ids, else: [my_gen_badge_ids]

    # ! modified my_gen_badge_ids after commented
    # badge_ids = if data["badges"], do: data["badges"].ids, else: parse_badges_string(data["badge_ids_string"], generalbadges_ids)
    # badge_ids_string = if data["badge_ids_string"], do: data["badge_ids_string"], else: Enum.join(data["badges"].ids, ",")

    render(conn, "edit.html",
      badges: general_badges,
      # badge_ids: badge_ids,
      # badge_ids_string: badge_ids_string,
      badge_ids: data["badges"].ids,
      badge_ids_string: Enum.join(data["badges"].ids, ","),
      # errors: params["errors"],
      personas: personas,
      ad: data["ad"],
      color: data["color"],
      lyout: data["layout"],
      see: data["see"],
      show: data["show"],
      layout: {LayoutView, "settings.html"}
    )
  end

  defp edit_data(persona, params) do
    # if params["options"] do
    #   params["options"]
    # else
      persona = persona |> Repo.preload([:privacy, :style])


      %{
        "ad"      => persona.style.settings["ad"],
        "badges"  => persona.id |> Groups.my_general_badges_group(),
        "color"   => persona.style.settings["color"],
        "layout"  => persona.style.settings["layout"],
        "see"     => persona.privacy.settings["see"],
        "show"    => persona.privacy.settings["show"]
      }
    # end
  end

  def index(conn, _params) do
    personas = Accounts.list_personas()
    render(conn, "index.html", personas: personas)
  end

  def new(conn, _params) do
    changeset = Accounts.change_persona(%Persona{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, _) do
    name = "generated"<>allocate_name()
    image_name = allocate_name()
    persona_params = %{image: image_name, left_at: Timex.now, name: name, user_id: get_persona(conn).user_id}

    case Accounts.create_persona(persona_params) do
      {:ok, persona} ->
        persona_id = persona.id
        upload_image(:profile, "./assets/static/images/profiles/avatar.jpg", image_name)
        Accounts.create_persona_associated_data(persona_id)

        conn = WorldbadgesWeb.Auth.logout(conn) |> Guardian.Plug.sign_in(persona)

        redirect(conn, to: persona_path(conn, :edit, persona))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
      end
  end

  def save_preferences(conn, %{"preferences" => params}) do
    persona = get_persona(conn)

    # TODO: reenable upload image
    cond do
      params["canvascontent"] not in ["", nil] -> upload_encoded_data(:profile, params["canvascontent"], persona.image<>".jpg")
      params["image_upload"]  not in ["", nil] ->
        file = params["image_upload"]
        params = params |> Map.delete("image_upload")
        if file.content_type in ["image/jpeg", "image/png"] do
          upload_image(:profile, file.path, persona.image)
        else
          # TODO make flash appear
          conn
          |> put_flash(:error, "Only jpeg or png images can be uploaded")
          redirect(conn, to: persona_path(conn, :edit, persona, options: params))
        end
      true -> nil
    end

    # update name
    # TODO: if update fails for name should at least update other stuff and not lose all preferences (aka use ajax)
    case Accounts.update_persona(persona, %{name: params["name"]}) do
      {:ok, persona} ->
        persona = persona |> Repo.preload([:contact, :privacy])
        contact = persona.contact

        generalbadges_ids = Groups.general_badges_group().ids
        old_mygenbadges_ids = Groups.my_general_badges_group(persona.id).ids
        new_mygenbadges_ids = parse_badges_string(params["badge_ids_string"], generalbadges_ids)

        # update my gen badges group
        if old_mygenbadges_ids != new_mygenbadges_ids,
        do: Groups.update_mygeneralbadges_group(persona.id, %{ids: new_mygenbadges_ids})

        # determine what page ids to add or remove
        added_ids   = new_mygenbadges_ids -- old_mygenbadges_ids
        removed_ids = old_mygenbadges_ids -- new_mygenbadges_ids


        if added_ids != [] || removed_ids != [] do
          added_pages_ids   = if added_ids   != [], do: Groups.page_ids_by_badges(added_ids)
          removed_pages_ids = if removed_ids != [], do: Groups.page_ids_by_badges(removed_ids)


          # UPDATE CONTACT GROUPS

          # remove page ids
          contact_groups = if removed_pages_ids do
            Enum.reduce(removed_pages_ids, contact.groups, fn(page_id, acc) ->
              Joins.delete_page_personas(page_id, persona.id)
              key = "#{page_id}"

              acc
              |> Map.delete(key)
              |> Map.update!("0", fn(ids) -> (ids ++ acc[key]) |> Enum.uniq() end)
            end)
          else
            contact.groups
          end

          contact_groups = if added_pages_ids do
            contacts = Groups.contact_for(contact.groups["0"])
            Enum.reduce(added_pages_ids, contact_groups, fn(page_id, acc) ->
              Joins.create_page_personas(%{page_id: page_id, persona_id: persona.id})
              key = "#{page_id}"
              contact_ids = contacts
                |> Enum.filter(fn(object) -> Map.has_key?(object.groups, key) end)
                |> Enum.map(&(&1.persona_id))

              acc
              |> Map.update!("0", &(&1 -- contact_ids))
              |> Map.update(key, contact_ids, &(&1 ++ contact_ids))
            end)
          else
            contact_groups
          end
          Groups.update_contact(contact, %{groups: contact_groups})

          # UPDATE SUBD PAGES
          subd_pages = Groups.subdpages_group(persona.id)
          new_ids = if removed_pages_ids, do: subd_pages.ids -- removed_pages_ids, else: subd_pages.ids
          new_ids = if added_pages_ids,   do: added_pages_ids ++ new_ids, else: new_ids
          Groups.update_page_group(subd_pages, %{ids: new_ids})
        end

        # UPDATE STYLE & PRIVACY

        Settings.update_style(persona.id, %{
          settings: %{color: params["color"], bg: bg(params["color"]), ad: params["ad"], layout: params["layout"]}
        })
        Settings.update_privacy(persona.id, %{
          settings: %{see: params["see"], show: params["show"], notifications: persona.privacy.settings["notifications"]}
        })

        send_resp(conn, 200, "")
      {:error, %Ecto.Changeset{} = changeset} ->
        errors = Enum.map(changeset.errors, fn({field, error}) ->
          elem(error, 0) |> String.capitalize()
        end)
        |> Enum.join("\n")

        send_resp(conn, 400, errors)
        # redirect(conn, to: persona_path(conn, :edit, persona, errors: %{"name" => errors}))
    end
  end

  def show(conn, params) do
    # update_cookie(conn, name)
    current_persona = get_persona(conn) |> Repo.preload(:style)

    events = Information.get_events(current_persona, 30)
    pages = Groups.pages_for(current_persona.id, default_page_limit(), 0)

    badge_ids = Groups.mybadges_group(current_persona.id).ids
    ad = Posting.get_random_ad(badge_ids)

    contact_ids = Groups.contact_ids_for(current_persona.id)
    persona = Accounts.get_persona!(params["id"]) |> Repo.preload(:privacy)
    public_articles = not persona.id in contact_ids

    articles = Posting.persona_articles(persona.id, public_articles, default_limit(), 0)
    article = if params["article_id"], do: Posting.get_article!(params["article_id"])
    [articles, comments] = cond do
      is_nil(article) || article.persona_id != persona.id -> [articles, nil]
      is_nil(article.visibility) || (article.visibility && !public_articles) ->
        articles = [article | (articles -- [article])]
        comments = Posting.comments_for_article(article.id, params["comment_id"], default_limit(), 0)
        [articles, comments]
      true -> [articles, nil]
    end
    articles = articles |> Repo.preload([:persona])

    render(conn, "show.html",
      ad: ad,
      add: add(current_persona, persona, contact_ids),
      articles: articles,
      comments: comments,
      current_persona: current_persona,
      events: events,
      pages: pages,
      persona: persona,
      persona_badges: persona_badges(persona, current_persona, contact_ids),
      layout: {LayoutView, "page.html"}
    )
  end

  defp add(current_persona, persona, contact_ids) do
    cond do
      current_persona.id == persona.id -> ""
      persona.id in contact_ids ->
        "<a href='#' class='btn btn-xs main-bg' data-report='user' data-type='user' data-id='#{persona.id}' style='float: right; margin-left: 1px'>" <>
          "Report" <>
        "</a>" <>
        "<a href='#' class='btn btn-xs main-bg' style='float: right; margin-left: 1px' onclick='addPersonaToContacts(this, \"#{persona.id}\", \"block\")'>" <>
          "Block" <>
        "</a>" <>
        "<a href='#' class='btn btn-xs main-bg' style='float: right; margin-left: 2em' onclick='addPersonaToContacts(this, \"#{persona.id}\", \"remove\")'>" <>
          "Remove" <>
        "</a>"
      Information.get_add_contact(current_persona.id, persona.id) -> "<a href='#' class='btn btn-xs main-bg' style='float: right;'>Pending</a>"
      Information.get_add_contact(persona.id, current_persona.id) ->
        "<a href='#' class='btn btn-xs main-bg' style='float: right; margin-left: 1px' onclick='addPersonaToContacts(this, \"#{persona.id}\", \"block\")'>" <>
          "<i class='fa fa-ban' aria-hidden='true'></i> Block" <>
        "</a>" <>
        "<a href='#' class='btn btn-xs main-bg' style='float: right; margin-left: 2em' onclick='addPersonaToContacts(this, \"#{persona.id}\", \"accept\")'>" <>
          "<i class='fa fa-user-plus' aria-hidden='true'></i> Accept" <>
        "</a>"
      Groups.is_blocked(persona.id, current_persona.id) ->
        "<a href='#' class='btn btn-xs main-bg' style='float: right; margin-left: 2em' onclick='addPersonaToContacts(this, \"#{persona.id}\", \"unblock\")'>" <>
          "<i class='fa fa-ban' aria-hidden='true'></i> Unblock" <>
        "</a>"
      true -> "<a href='#' class='btn btn-xs main-bg' style='float: right; margin-left: 2em' onclick='addPersonaToContacts(this, \"#{persona.id}\", \"request\")'><i class='fa fa-user-plus' aria-hidden='true'></i> Add</a>"
    end
  end

  # def add_persona(conn, %{"id" => id, "page" => page_name}) do
  #   current_persona = get_persona(conn)
  #   page = page_name |> unparse_name() |> Groups.get_page_by_name!()
  #   persona = Accounts.get_persona_by_id!(id) |> Repo.preload()
  #
  #   cond do
  #     # persona && persona.id == current_persona.id -> send_resp(conn, 400, "Can not remove self")
  #     page && persona && page.persona_id == current_persona.id && not Groups.page_member?(page.id, persona.id) ->
  #       #TODO: check for admin privileges
  #       Joins.create_page_personas(%{page_id: page.id, persona_id: persona.id})
  #       subdgroup = Groups.subdpages_group(persona.id)
  #       Groups.update_page_group(subdgroup, %{ids: [page.id | subdgroup.ids]})
  #
  #       send_resp(conn, 200, "")
  #     true -> send_resp(conn, 400, "Operation failed. Please notify our help support.")
  #   end
  # end

  def delete_account(conn, _) do
    # TODO have an icon to notify the persona and others that his account is up for deletion
    persona = get_persona(conn)
    case Worldbadges.Operations.create_delete_task(%{type: "persona", obj_id: persona.id}) do
      {:ok, delete_task} ->
        Accounts.update_persona(persona, %{delete: true})
        send_resp(conn, 200, "")
      {:error, %Ecto.Changeset{} = changeset} ->
        send_resp(conn, 400, "Operation failed. Please notify our help support.")
    end
  end

  def revoke_account_deletion(conn, _) do
    persona = get_persona(conn)
    {nr_deletes, _} = Worldbadges.Operations.remove_delete_task("persona", persona.id)
    if nr_deletes > 0 do
      Accounts.update_persona(persona, %{delete: false})
      send_resp(conn, 200, "")
    else
      send_resp(conn, 400, "Account deletion was already revoked or never initiated. If you are having issues please notify our help support.")
    end
  end

  def reserve_account(conn, %{"months" => months}) do
    # TODO: actually reserve
    send_resp(conn, 200, "")
  end

  # def search_non_members(conn, %{"input" => input, "page" => page_name}) do
  #   cond do
  #     not String.match?(input, ~r/^[a-zA-Z \d-]{2,30}$/) ->
  #       send_resp(conn, 400, "Invalid search pattern. Can only use spaces, numbers, letters and hiphens and must be between 2 and 30 characters long")
  #     true ->
  #       page = Groups.get_persona_page!(page_name, get_persona(conn).id) # TODO: allow admins to search for page too
  #       html = "%#{input}%"
  #         |> Accounts.search_non_members(page.id) # TODO: improve search (use limit to get less results)
  #         |> Enum.reduce("", fn(persona, acc) ->
  #           acc <>
  #           "<div>" <>
  #           "<img src=#{image_for_persona(persona)} class='small-badge'> #{persona.name} " <>
  #           "<button type='button' name='button' class='btn btn-sm main-bg' onclick=\"personaToPageAction('invite', this, '#{parse_name(page.name)}', '#{persona.id}')\">Invite persona</button>" <>
  #           "</div>"
  #         end)
  #       send_resp(conn, 200, html)
  #   end
  # end

  def edit(conn, _) do
    changeset = get_persona(conn) |> Accounts.change_persona()
    render(conn, "edit.html", changeset: changeset, layout: {LayoutView, "page.html"})
  end

  def update(conn, %{"persona" => params}) do
    persona = get_persona(conn)

    persona_params = if params["key"] == "", do: Map.delete(params, "key"), else: params
    case Accounts.update_persona(persona, persona_params) do
      {:ok, persona} ->
        redirect(conn, to: shared_path(conn, :settings))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", persona: persona, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    persona = Accounts.get_persona!(id)
    {:ok, _persona} = Accounts.delete_persona(persona)

    conn
    |> put_flash(:info, "Ad deleted successfully.")
    |> redirect(to: persona_path(conn, :index))
  end

  defp bg(color) do
    case color do
      "rgb(255, 174, 188)" -> "#ffdae1" #pinkish
      "purple" -> "#d1c5d0"
      "brown" -> "#d1c5c5"
      "orange" -> "#ddd4c6"
      "green" -> "#d1c5c5"
      "steelblue" -> "#accce7"
      "black" -> "#717171"
      _ -> "#d1c5d0"
    end
  end

  defp parse_badges_string(string, generalbadges_ids) do
    string
    |> String.split(",")
    |> Enum.reduce([], fn(badge_id, acc) ->
      id = String.to_integer(badge_id)
      if id in generalbadges_ids, do: [id | acc], else: acc
    end)
  end

  defp persona_badges(persona, current_persona, contact_ids) do
    show = persona.privacy.settings["show"]

    cond do
      show == "open" || (show == "trusted" && persona.id in contact_ids) ->
        Groups.subd_badges(persona.id)
      show in ["trusted", "separated"] ->
        ids1 = Groups.mygeneralbadges_group(current_persona.id).ids
        ids2 = Groups.mygeneralbadges_group(persona.id).ids
        Enum.filter(ids1, fn(id) -> id in ids2 end) |> Features.get_badges()
    end
  end

end
