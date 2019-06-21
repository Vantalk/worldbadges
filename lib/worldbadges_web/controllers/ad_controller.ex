defmodule WorldbadgesWeb.AdController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.{
    Groups,
    Posting,
    Posting.Ad
  }

  import WorldbadgesWeb.Shared, only: [allocate_name: 0, get_persona: 1, unparse_name: 1, upload_image: 3]

  def index(conn, _params) do
    ads = Posting.list_ads()
    render(conn, "index.html", ads: ads)
  end

  def new(conn, _params) do
    persona = get_persona(conn)
    changeset = Posting.change_ad(%Ad{})
    badges = Groups.my_badges(get_persona(conn).id)
    general_badges = Groups.general_badges()
    pages = Worldbadges.Groups.pages_for(persona.id)

    render(conn, "new.html", changeset: changeset, general_badges: general_badges, targets: [], type: nil, pages: pages, layout: {WorldbadgesWeb.LayoutView, "settings.html"})
  end

  def create(conn, %{"ad" => params}) do
    file = params["image"]
    name = unparse_name(params["name"])
    persona = get_persona(conn)

    [targets, errors] = create_errors(file, name, persona, params)

    if errors != []  do
      send_resp(conn, 400, Enum.join(errors, "\n"))
    else
      url = with "" <- String.trim(params["url"]), do: "#"

      # TODO try to directly save and retry different generated hex name on fail
      file_name = allocate_name()

      ad_params = %{name: name, image: file_name, url: url, targets: targets, persona_id: persona.id}
      result = if params["civic"] == "true",
        do: Posting.create_civic_ad(ad_params),
        else: Posting.create_ad(ad_params)

      case result do
        {:ok, ad} ->
          upload_image(:ad, file.path, file_name)
          send_resp(conn, 200, "")
        {:error, %Ecto.Changeset{} = changeset} ->
          errors = Enum.map(changeset.errors, fn({field, error}) ->
            "#{field} #{elem(error, 0)}" |> String.capitalize()
          end)
          |> Enum.join("\n")

          send_resp(conn, 400, errors)
      end
    end
  end

  def show(conn, %{"name" => name}) do
    persona = get_persona(conn)
    ad = Posting.get_ad(name, persona.id)
    render(conn, "show.html", ad: ad, pages: Worldbadges.Groups.pages_for(persona.id), layout: {WorldbadgesWeb.LayoutView, "settings.html"})
  end

  def edit(conn, params) do
    persona = get_persona(conn)
    [ad, changeset, type] = get_ad(params, persona.id)
    general_badges = Groups.general_badges()

    render(conn, "edit.html", ad: ad, changeset: changeset, general_badges: general_badges, pages: Worldbadges.Groups.pages_for(persona.id), type: type, targets: ad.targets, layout: {WorldbadgesWeb.LayoutView, "settings.html"})
  end

  defp get_ad(params, persona_id) do
    if params["ad_name"] do
      ad = unparse_name(params["ad_name"]) |> Posting.get_ad!(persona_id)
      [ad, Posting.change_ad(ad), "ad"]
    else
      ad = unparse_name(params["civic_ad_name"]) |> Posting.get_civic_ad!(persona_id)
      [ad, Posting.change_civic_ad(ad), "civic_ad"]
    end
  end

  def update(conn, %{"name" => name, "ad" => params}) do
    persona = get_persona(conn)
    name = unparse_name(name)
    type = params["type"]
    [ad, update, delete] = if type == "ad" do
      [
        Posting.get_ad!(name, persona.id),
        &Posting.update_ad/2,
        &Posting.delete_ad/1
      ]
    else
      [
        Posting.get_civic_ad!(name, persona.id),
        &Posting.update_civic_ad/2,
        &Posting.delete_civic_ad/1
      ]
    end

    if (type == "ad" && params["civic"] == "true") || (type == "civic_ad" && params["civic"] == "false") do
      create(conn, %{"ad" => params})
      delete.(ad)
    else
      new_name = unparse_name(params["name"])
      [targets, errors] = update_errors(ad, params["image"], new_name, persona, params)

      if errors != [] do
        send_resp(conn, 400, Enum.join(errors, "\n"))
      else
        url = with "" <- String.trim(params["url"]), do: "#"
        if file = params["image"] do
          upload_image(:ad, file.path, ad.image)
        end

        status = determine_status(ad, params["image"], url, targets)
        ad_params = %{name: new_name, url: url, targets: targets, status: status}
        update.(ad, ad_params) |> handle_response(new_name, conn)
      end
    end
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

  defp determine_status(ad, new_image, url, targets) do
    cond do
      new_image             -> "pending: Your changes are queued for approval"
      ad.url != url         -> "pending: Your changes are queued for approval"
      ad.targets != targets -> "pending: Your changes are queued for approval"
      true                  -> ad.status
    end
  end

  def delete(conn, %{"id" => id}) do
    ad = Posting.get_ad!(id)
    {:ok, _ad} = Posting.delete_ad(ad)

    conn
    |> put_flash(:info, "Ad deleted successfully.")
    |> redirect(to: ad_path(conn, :index))
  end

  defp create_errors(file, name, persona, params) do
    errors = if file == nil, do: ["No image uploaded"], else: []
    #TODO Disallow other file type uploads from Plug.Upload
    errors = if errors == [] && not file.content_type in ["image/jpeg", "image/png"], do: ["Only jpg or png image formats allowed" | errors], else: errors
    # errors = if errors == [] && String.length(file.filename) > 30, do: ["File name too long. Maximum 30 characters permitted" | errors], else: errors
    # errors = if errors == [] && not String.match?(file.filename, ~r/^[a-zA-Z \d-]*\.((jpeg)|(jpg)|(png))$/), do: ["File name can only contain spaces, numbers, letters, hiphens and underscores" | errors], else: errors

    errors = if name == "", do: ["Name can't be blank" | errors], else: errors
    errors = if not String.match?(name, ~r/^[a-zA-Z \d-]{2,30}$/), do: ["Name can only contain spaces, numbers, letters and hiphens and must be at least 2 characters long" | errors], else: errors

    errors = cond do
      params["civic"] == "true" && Posting.get_civic_ad(name, persona.id) -> ["You already have a civic ad with this name" | errors]
      params["civic"] == "false" && Posting.get_ad(name, persona.id) -> ["You already have an ad with this name" | errors]
      true -> errors
    end

    [targets, errors] = cond do
      params["civic"] == "false" && params["targets"] == "" ->
        errors = ["No target interests selected" | errors]
        [nil, errors]
      params["civic"] == "false" && params["targets"] != "" -> [get_record_ids(params["targets"]), errors]
      params["civic"] == "true" -> [nil, errors]
    end
  end

  defp update_errors(ad, file, name, persona, params) do
    errors = if file && not file.content_type in ["image/jpeg", "image/png"], do: ["Only jpg or png image formats allowed"], else: []
    # errors = if name == "", do: ["Name can't be blank" | errors], else: errors
    errors = if not String.match?(name, ~r/^[a-zA-Z \d-]{2,30}$/), do: ["Name can only contain spaces, numbers, letters and hiphens and must be at least 2 characters long" | errors], else: errors

    errors = cond do
      ad.name == name -> errors
      params["civic"] == "true" && Posting.get_civic_ad(name, persona.id) -> ["You already have an ad with this name" | errors]
      params["civic"] == "false" && Posting.get_ad(name, persona.id) -> ["You already have an ad with this name" | errors]
      true -> errors
    end

    [targets, errors] = cond do
      params["civic"] == "false" && params["targets"] == "" ->
        errors = ["No target interests selected" | errors]
        [nil, errors]
      params["civic"] == "false" && params["targets"] != "" -> [get_record_ids(params["targets"]), errors]
      params["civic"] == "true" -> [nil, errors]
    end
  end

  defp get_record_ids(names_string) do
    name_mapping =
      Worldbadges.Groups.general_pages() #records
      |> Enum.reduce(%{}, fn(record, acc) -> Map.put(acc, record.name, record.id) end)

    names =
      names_string
      |> URI.decode()
      |> String.split("/")
      |> Enum.reduce([], fn(name, acc) -> if id = name_mapping[name], do: [id | acc], else: acc end)
  end

end
