defmodule WorldbadgesWeb.PageController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.{
    Accounts,
    Features,
    Groups,
    Groups.Page,
    Posting,
    Repo
  }

  alias WorldbadgesWeb.LayoutView
  import WorldbadgesWeb.Shared, only: [default_limit: 0, default_page_limit: 0, get_persona: 1, parse_name: 1, unparse_name: 1]

  def index(conn, _params) do
    persona = conn.assigns[:current_persona] |> Repo.preload([:interest_articles, :style, :privacy])
    events = Worldbadges.Information.get_events(persona, 30)
    include_persona_artiles = persona.privacy.settings["see"] == "open"

    # TODO: when current_persona privacy is "closed(separated)" consider option to show
    # persona articles only if they are tagged with the interests that current_persona is interested in
    articles = Posting.articles_for_persona(persona, include_persona_artiles, default_limit(), 0) |> Repo.preload(:persona) |> Repo.preload(:page)

    [layout, page_limit] = if persona.style.settings["layout"] == "grouped",
      do: ["index_layout2.html", default_limit()],
    else: ["index.html", default_page_limit()]

    pages = Groups.pages_for(persona.id, page_limit, 0)
    # contact_ids = Groups.contacts_group_for(persona.id).ids

    # TODO: get limited amount of badges
    badge_ids = Groups.mybadges_group(persona.id).ids
    # badges = Features.get_badges!(badge_ids)
    # TODO: select number of ads according to persona setting, interests and fill if none
    ad = Posting.get_random_ad(badge_ids)

    render(conn, layout,
      ad: ad,
      articles: articles,
      # badges: badges,
      # contacts: contacts,
      current_persona: persona,
      events: events,
      pages: pages,
      layout: {LayoutView, "page.html"}
    )
  end

  def new(conn, _params) do
    # TODO: only get unused badges (create method in Features)
    persona = conn.assigns[:current_persona] |> Repo.preload(:badges)
    changeset   = Groups.change_page(%Page{})
    subd_pages  = Groups.pages_for(persona.id)

    render(conn, "new.html", changeset: changeset, subd_pages: subd_pages, persona_badges: persona.badges, pages: Worldbadges.Groups.pages_for(persona.id), layout: {LayoutView, "settings.html"})
  end

  def create(conn, %{"page" => params}) do
    persona = conn.assigns[:current_persona]
    name = params["name"] |> String.trim()
    [badge_id, badge_image, parent, errors] = create_errors(params, name, persona)

    if errors != [] do
      send_resp(conn, 400, Enum.join(errors, "\n"))
    else
      page_params = params
      |> Map.put("name", name)
      |> Map.put("persona_id", persona.id)
      |> Map.put("badge_id", badge_id)
      |> Map.put("parent_page_id", parent.id)
      |> Map.put("general_page_id", parent.general_page_id)
      |> Map.put("image", badge_image)
      |> Map.put("roles", %{"mods" => [], "admins" => [persona.id]})

      # TODO: if parent page is general page maybe wait for approval (2nd tier page)
      case Groups.create_page(page_params) do
        {:ok, page} ->
          Groups.create_pending_persona(%{page_id: page.id})
          group = Groups.mypages_group(persona.id)
          ids = [page.id | group.ids]
          Groups.update_page_group(group, %{ ids: ids })

          group = Groups.subdpages_group(persona.id)
          ids = [page.id | group.ids] |> Groups.get_pages() |> Enum.sort_by(&String.downcase(&1.name)) |> Enum.map(&(&1.id))
          Groups.update_page_group(group, %{ ids: ids })

          Worldbadges.Joins.create_page_personas(%{page_id: page.id, persona_id: persona.id})

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

  def search(conn, params) do
    persona_id = get_persona(conn).id
    pages = Groups.pages_for(persona_id, default_page_limit(), 0)

    input = params["input"]
    ids = if params["ids"], do: params["ids"], else: []
    [message, page_results, persona_results] = cond do
      is_nil(input) -> [nil, [], []] #|| (not is_nil(input) && String.trim(input) == "") -> [nil, [], []]
      String.trim(input) != "" && not String.match?(input, ~r/^[a-zA-Z \d-]{2,30}$/) -> ["Invalid search pattern. Can only use spaces, numbers, letters and hiphens and must be between 2 and 30 characters long", [], []]
      true ->
        input = "%#{input}%"
        # TODO: improve search (use limit to get less results)
        page_results = Groups.search_pages(ids, input)
        persona_results = Accounts.search_personas(ids, input)
        [nil, page_results, persona_results]
    end

    render(conn, "search.html", message: message, pages: pages, page_results: page_results, persona_results: persona_results, layout: {LayoutView, "page.html"})
  end

  def show(conn, params) do
    persona = conn.assigns[:current_persona] |> Repo.preload([:badge_groups, :style])
    page = params["name"] |> unparse_name() |> Groups.get_page_by_name!() |> Repo.preload(:pending_persona)

    # update_cookie(conn, name)
    # TODO: get all
    ad = Posting.get_random_ad([page.badge_id])
    # TODO: enable specific articles
    articles = Posting.articles_for_pages([page.id], default_limit(), 0)
    article = if params["article_id"], do: Posting.get_page_article(params["article_id"], page.id)
    [articles, comments] = if article do
      articles = [article | (articles -- [article])]
      comments = if params["comment_id"] do
        Posting.comments_for_article(article.id, params["comment_id"], round(default_limit()/2), 0)
      else
        Posting.comments_for_article(article.id, nil, default_limit(), 0)
      end
      [articles, comments]
    else
      [articles, nil]
    end
    articles = articles |> Repo.preload(:persona)

    badges = Groups.my_badges(persona.id)
    pages = Groups.pages_with_exception_for(persona.id, [page.id], default_page_limit()-1, 0)
    events = []
    admin? = persona.id in page.roles["admins"]
    member? = admin? || Groups.page_member?(page.id, persona.id)

    render(conn, "show.html",
      ad: ad,
      admin?: admin?,
      articles: articles,
      badges: badges,
      comments: comments,
      current_persona: persona,
      events: events,
      member?: member?,
      page: page,
      pages: [page | pages],
      layout: {LayoutView, "page.html"}
    )
  end

  def edit(conn, %{"name" => name}) do
    persona = get_persona(conn)
    name = unparse_name(name)
    page = Groups.get_persona_page!(name, persona.id) |> Repo.preload([:badge, :personas, :pending_persona])

    changeset     = Groups.change_page(page)
    subd_pages    = Groups.pages_for(persona.id)
    persona_badges   = Groups.persona_badges(persona.id)
    invited_personas = Accounts.get_personas(page.pending_persona.invites)
    waiting_personas = Accounts.get_personas(page.pending_persona.requests)

    render(conn, "edit.html",
      page: page,
      changeset: changeset,
      invited_personas: invited_personas,
      page_personas: page.personas,
      pages: Groups.pages_for(persona.id),
      subd_pages: subd_pages,
      persona_badges: persona_badges,
      waiting_personas: waiting_personas,
      layout: {LayoutView, "settings.html"}
    )
  end

  def update(conn, %{"name" => name, "page" => params}) do
    persona = get_persona(conn)
    name = unparse_name(name)
    page = Groups.get_persona_page!(name, persona.id)
    [badge_id, badge_image, errors] = update_errors(params, params["name"], page, persona)

    if errors != [] do
      send_resp(conn, 400, Enum.join(errors, "\n"))
    else
      page_params = params
      |> Map.put("name", params["name"])
      |> Map.put("badge_id", badge_id)
      |> Map.put("image", badge_image)
      # do not allow change of parent (needs approval)
      |> Map.put("parent_page_id", page.parent_page_id)
      |> Map.put("general_page_id", page.general_page_id)

      case Groups.update_page(page, page_params) do
        {:ok, page} ->
          send_resp(conn, 200, "")
        {:error, %Ecto.Changeset{} = changeset} ->
          errors = Enum.map(changeset.errors, fn({field, error}) ->
            "#{field} #{elem(error, 0)}" |> String.capitalize()
          end)

          send_resp(conn, 400, Enum.join(errors, "\n"))
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    page = Groups.get_page!(id)
    {:ok, _page} = Groups.delete_page(page)

    conn
    |> put_flash(:info, "Page deleted successfully.")
    |> redirect(to: page_path(conn, :index))
  end

  defp update_cookie(conn, page_name) do
    # TODO: explore best way to serve for high number of rooms and index page(mix of posts); where use caching?

    domain = "d3qkdn8okbf6qt.cloudfront.net" # TODO: update to subdomain.mywebsite.com using cloudfront alternate name (cname)
    file_link = "https://#{domain}/#{page_name}"  # TODO: use folder; sanitize
    expire_time = 1512086400 # TODO: dinamically make it 24h after today

    # AWS json policy
    policy =
      %{"Statement"=> [%{
          "Resource" => file_link,
          "Condition"=>%{"DateLessThan" =>%{"AWS:EpochTime"=> expire_time}}
      }]} |> Poison.encode!([])

    # Key for AWS signature
    key = File.read!("priv/pk.pem") |> :public_key.pem_decode |> hd |> :public_key.pem_entry_decode

    # AWS signature (accepts only :sha encoding - usually known as sha1 )
    signature = policy |> :public_key.sign(:sha, key) |> Base.encode64

    # TODO: use domain variable
    conn = conn
    |> Plug.Conn.put_resp_cookie("CloudFront-Policy", policy |> Base.encode64, [domain: "localhost"])
    |> Plug.Conn.put_resp_cookie("CloudFront-Signature", signature, [domain: "localhost"])
    |> Plug.Conn.put_resp_cookie("CloudFront-Key-Pair-Id", "APKAJGD7T6GFPYBIEKPQ", [domain: "localhost"])

    {conn, file_link}
  end

  defp create_errors(params, name, persona) do
    [badge_id, badge_image, badge_error] = badge_errors?(params["badge_name"], persona.id)
    [parent, parent_error] = parent_errors?(params["parent_name"], persona.id)
    errors = [badge_error, parent_error] |> Enum.filter(fn(error) -> error != nil end)
    errors = if not String.match?(name, ~r/^[a-zA-Z \d-]{2,30}$/), do: ["Name can only contain spaces, numbers, letters and hiphens and must be at least 2 characters long" | errors], else: errors

    [badge_id, badge_image, parent, errors]
  end

  defp update_errors(params, new_name, page, persona) do
    [badge_id, badge_image, badge_error] = badge_errors?(params["badge_name"], persona.id, page.id)
    errors = if badge_error, do: [badge_error], else: []
    errors = if not String.match?(new_name, ~r/^[a-zA-Z \d-]{2,30}$/), do: ["Name can only contain spaces, numbers, letters and hiphens and must be at least 2 characters long" | errors], else: errors
    errors =  Enum.filter(errors, fn(error) -> error != nil end)

    [badge_id, badge_image, errors]
  end

  defp badge_errors?(badge_name, persona_id, page_id \\ 0) do
    if badge_name in ["", "Placeholder"] do
      [nil, "Placeholder", nil]
    else
      badge = badge_name
        |> unparse_name()
        |> Features.get_badge(persona_id)
        |> Repo.preload(:page)
      error = if badge.page && badge.page.id != page_id, do: "Badge in use for another page" #Already taken

      [badge.id, badge.image, error]
    end
  end

  defp parent_errors?(parent_name, persona_id) do
    if parent_name == "" do
      [nil, "No parent interest associated"]
    else
      page = parent_name
      |> unparse_name()
      |> Groups.get_page_by_name!()
      error = if not page.id in Groups.subdpages_group(persona_id).ids, do: "Invalid parent page"

      [page, error]
    end
  end

end
