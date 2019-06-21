defmodule WorldbadgesWeb.GroupController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.Groups

  import WorldbadgesWeb.Shared, only: [unparse_name: 1]

  def new(conn, _params) do
    persona = conn.assigns[:current_persona] |> Repo.preload(:contact)
    pages    = Groups.pages_for(persona.id)
    contacts = Groups.contacts_for(persona)

    render(conn, "new.html", contacts: contacts, pages: pages, layout: {WorldbadgesWeb.LayoutView, "settings.html"})#, changeset: changeset, #badges: badges, general_badges: general_badges, layout: {WorldbadgesWeb.LayoutView, "settings.html"})
  end

  defp preliminary_errors(ids, name) do
    errors = if length(ids) < 2, do: ["Must select at least two group items"], else: []
    errors = if not String.match?(name, ~r/^[a-zA-Z \d-,\.\!:]{2,30}$/), do: ["Name can only contain letters, numbers, spaces and the folowing symbols: .,-:! and must be between 2 and 30 characters long" | errors], else: errors
    errors = if name in ["General pages", "MyPages", "SubdPages", "General badges", "MyBadges", "MyGeneralBadges"],
      do: ["Name reserved. Please choose another" | errors], else: errors
  end

  defp handle_response({atom, response}, name, conn) do
    if atom == :ok do
      send_resp(conn, 200, "")
    else
      errors = Enum.map(response, fn({field, error}) ->
        "#{field} #{elem(error, 0)}" |> String.capitalize()
      end)

      send_resp(conn, 400, Enum.join(errors, "\n"))
    end
  end

  def create(conn, %{"group" => params}) do
    persona = conn.assigns[:current_persona] |> Repo.preload(:contact)
    ids  = if is_list(params["elements"]), do: params["elements"], else: get_record_ids(params["type"], params["elements"], persona)
    name = params["name"] |> String.trim()
    # group = if params["type"] == "pages", do: Groups.get_page_group(persona.id, name), else: Groups.get_persona_group(persona.id, name)
    group = Groups.get_persona_group(persona.id, name)

    errors = preliminary_errors(ids, name)
    errors = if errors == [] && group, do: ["You already have a group with this name" | errors], else: errors

    if errors != [] do
      send_resp(conn, 400, Enum.join(errors, "\n"))
    else
      # case params["type"] do
      #   "pages"    -> Groups.create_page_group(%{persona_id: persona.id, name: name, ids: ids})
      #   "contacts" -> Groups.create_persona_group(%{persona_id: persona.id, name: name, ids: ids})
      # end |> handle_response(name, conn)
      Groups.create_persona_group(%{persona_id: persona.id, name: name, ids: ids})
      |> handle_response(name, conn)
    end
  end

  def show(conn, %{"id" => id}) do
    ad = Posting.get_ad!(id)
    render(conn, "show.html", ad: ad)
  end

  # def edit_page_group(conn, %{"name" => name}) do
  #   persona = conn.assigns[:current_persona]
  #   name = unparse_name(name)
  #   group = Groups.get_page_group!(name, persona.id)
  #   changeset = Groups.change_page_group(group)
  #   group_elements = Groups.get_pages(group.ids)
  #   pages    = Groups.pages_for(persona.id)
  #   contacts = Groups.contacts_for(persona.id)
  #
  #   render(conn, "edit.html", changeset: changeset, group: group, group_elements: group_elements, group_type: "pages", pages: pages, contacts: contacts, layout: {WorldbadgesWeb.LayoutView, "settings.html"})
  # end

  def edit_persona_group(conn, %{"name" => name}) do
    persona = conn.assigns[:current_persona] |> Repo.preload(:contact)
    name = unparse_name(name)
    group = Groups.get_persona_group!(name, persona.id)
    changeset = Groups.change_persona_group(group)
    group_elements = Worldbadges.Accounts.get_personas(group.ids)
    pages    = Groups.pages_for(persona.id)
    contacts = Groups.contacts_for(persona)

    render(conn, "edit.html", changeset: changeset, group: group, group_elements: group_elements, group_type: "contacts", pages: pages, contacts: contacts, layout: {WorldbadgesWeb.LayoutView, "settings.html"})
  end

  def update(conn, %{"group" => %{"elements" => names_string, "name" => new_name, "type" => type}, "group_type" => group_type, "name" => name}) do
    persona = conn.assigns[:current_persona] |> Repo.preload(:contact)
    ids = get_record_ids(type, names_string, persona)
    new_name = String.trim(new_name)
    # [group, update, delete] = if group_type == "pages" do
    #   [
    #     Groups.get_page_group!(name, persona.id),
    #     &Groups.update_page_group/2,
    #     &Groups.delete_page_group/1,
    #   ]
    # else
    #   [
    #     Groups.get_persona_group!(name, persona.id),
    #     &Groups.update_persona_group/2,
    #     &Groups.delete_persona_group/1,
    #   ]
    # end

    errors = preliminary_errors(ids, new_name)

    if errors != [] do
      send_resp(conn, 400, Enum.join(errors, "\n"))
    else
      group_params = %{"ids" => ids, "name" => new_name}
      # if type != group_type do
      #   delete.(group)
      #   create(conn, %{"group" => group_params})
      # else
      #   update.(group, group_params) |> handle_response(new_name, conn)
      # end
      Groups.get_persona_group!(name, persona.id)
      |> Groups.update_persona_group() |> handle_response(new_name, conn)
    end
  end

  def delete(conn, %{"id" => id}) do
    ad = Posting.get_ad!(id)
    {:ok, _ad} = Posting.delete_ad(ad)

    conn
    |> put_flash(:info, "Ad deleted successfully.")
    |> redirect(to: ad_path(conn, :index))
  end

  defp get_record_ids(type, names_string, persona) do
    records = if type == "pages", do: Groups.pages_for(persona.id), else: Groups.contacts_for(persona)

    name_mapping = Enum.reduce(records, %{}, fn(record, acc) ->
      name = manage_duplicate_name(record.name, acc)
      Map.put(acc, name, record.id)
    end)

    names =
      names_string
      |> URI.decode()
      |> String.split("/")
      |> Enum.reduce([], fn(name, acc) -> if id = name_mapping[name], do: [id | acc], else: acc end)
  end

  defp manage_duplicate_name(name, names, count \\ 0) do
    count = count + 1

    if names[name] do
      name = name <> "_#{count}"
      manage_duplicate_name(name, names, count)
    else
      name
    end
  end

end
