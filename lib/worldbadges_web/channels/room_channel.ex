defmodule WorldbadgesWeb.RoomChannel do
  use WorldbadgesWeb, :channel

  import WorldbadgesWeb.ChannelsShared, only: [current_persona: 1, get_article_data_from_content: 3, persona_id: 1, view_page?: 2]
  import WorldbadgesWeb.Shared, only: [admin?: 2, allocate_name: 0, contact_ids: 1, default_limit: 0, image_for_persona: 1, image_for_page: 1, link_for_persona: 1, mod_or_admin?: 2, page_membership_actions: 2,  parse_name: 1, unparse_name: 1]

  alias WorldbadgesWeb.{ChatModule, PostingModule}
  alias Worldbadges.{Accounts, Groups, Joins, Information, Posting, Repo}
  alias WorldbadgesWeb.MyPresence
  # use WorldbadgesWeb.MyPresence

  # --------------------------- JOIN METHODS ----------------------------------

  def join("room:" <> subtopic, params, socket) do
    IO.inspect params

    cond do
      persona_room?(socket, subtopic) -> send(self(), {:page, params}); {:ok, socket}
      view_page?(socket, subtopic) -> send(self(), {:page, params}); {:ok, socket}
      # join_chat?(socket, subtopic) -> send(self(), {:chat, params}); {:ok, socket}
      true -> {:error, "You are not allowed to join this channel"}
    end
  end
  def join(_other, _params, _socket) do
    {:error, "Room does not exist."}
  end

  def handle_info({:page, params}, socket) do
    handle_info(:after_join, socket)
    PostingModule.handle_info({:page, params}, socket)
  end
  def handle_info({:chat, params}, socket) do
    handle_info(:after_join, socket)
    ChatModule.handle_info({:chat, params}, socket)
  end

  def handle_info(:after_join, socket) do #= %{assigns: %{user_id: user_id}}) do
    # require IEx
    # IEx.pry()
    persona = current_persona(socket) |> Repo.preload(:contact)
    friend_list = contact_ids(persona.contact)
    presence_state = get_and_subscribe_presence_multi socket, friend_list
    IO.puts "------------------"
    IO.inspect presence_state
    push socket, "presence_state", presence_state
    track_user_presence(persona)
    # {:noreply, socket}
  end

  defp get_and_subscribe_presence_multi(socket, user_ids) do
    user_ids
      |> Enum.map(&presence_topic/1)
      |> Enum.uniq
      |> Enum.map(fn topic ->
           :ok = Phoenix.PubSub.subscribe(
             socket.pubsub_server,
             topic,
             fastlane: {socket.transport_pid, socket.serializer, []}
           )
           MyPresence.list(topic)
         end)
      |> Enum.reduce(%{}, fn map, acc -> Map.merge(acc, map) end)
  end

  defp presence_topic(user_id) do
    "user_presence:#{user_id}"
  end

  # Track the current process as a presence for the given user on it's designated presence topic
  defp track_user_presence(user) do
    {:ok, _} = MyPresence.track(self(), presence_topic(user.id), user.image, %{
      # online_at: inspect(System.system_time(:seconds))
    })
  end

  def handle_in("update_left_at", params, socket) do
    Accounts.update_left_at(persona_id(socket))
    {:noreply, socket}
  end

  # end of -------------------- JOIN METHODS ----------------------------------

  # --------------------------- CHAT MODULE METHODS ---------------------------

  def handle_in("chat:create", params, socket) do
    ChatModule.handle_in("chat:create", params, socket)
  end

  def handle_in("chat:get_events", params, socket) do
    ChatModule.handle_in("chat:get_events", params, socket)
  end

  def handle_in("chat:message_create", params, socket) do
    ChatModule.handle_in("chat:message_create", params, socket)
  end

  def handle_in("chat:wchat_open", params, socket) do
    ChatModule.handle_in("chat:wchat_open", params, socket)
  end
  #
  # def handle_in("messages:get_more", params, socket) do
  #   PostingModule.handle_in("messages:get_more", params, socket)
  # end

  # end of -------------------- CHAT MODULE METHODS ---------------------------

  # --------------------------- POSTING MODULE METHODS ------------------------

  def handle_in("posting:comments_show", params, socket) do
    PostingModule.handle_in("posting:comments_show", params, socket)
  end

  def handle_in("posting:comment_create", params, socket) do
    PostingModule.handle_in("posting:comment_create", params, socket)
  end

  def handle_in("posting:display_edit", params, socket) do
    PostingModule.handle_in("posting:display_edit", params, socket)
  end

  def handle_in("posting:delete_article", params, socket) do
    PostingModule.handle_in("posting:delete_article", params, socket)
  end

  def handle_in("posting:delete_comment", params, socket) do
    PostingModule.handle_in("posting:delete_comment", params, socket)
  end

  def handle_in("posting:enable_article_options", params, socket) do
    PostingModule.handle_in("posting:enable_article_options", params, socket)
  end

  def handle_in("posting:enable_comment_options", params, socket) do
    PostingModule.handle_in("posting:enable_comment_options", params, socket)
  end

  def handle_in("posting:get_events", params, socket) do
    PostingModule.handle_in("posting:get_events", params, socket)
  end

  def handle_in("posting:page_article_create", params, socket) do
    PostingModule.handle_in("posting:page_article_create", params, socket)
  end

  def handle_in("posting:persona_article_create", params, socket) do
    PostingModule.handle_in("posting:persona_article_create", params, socket)
  end

  def handle_in("posting:recognize", params, socket) do
    PostingModule.handle_in("posting:recognize", params, socket)
  end

  def handle_in("posting:report_article", params, socket) do
    PostingModule.handle_in("posting:report_article", params, socket)
  end

  def handle_in("posting:report_comment", params, socket) do
    PostingModule.handle_in("posting:report_comment", params, socket)
  end
  # end of -------------------- POSTING MODULE METHODS ------------------------

  # --------------------------- NO MODULE METHODS -----------------------------

  def handle_in("search_non_members", %{"input" => input, "page_name" => page_name}, socket) do
    elem = "non-members"
    html = if not String.match?(input, ~r/^[a-zA-Z \d-]{2,30}$/) do
      "Invalid search pattern. Can only use spaces, numbers, letters and hiphens and must be between 2 and 30 characters long"
    else
      page = unparse_name(page_name) |> Groups.get_page_by_name!()
      persona_id = persona_id(socket) |> String.to_integer()

      if page.persona_id == persona_id || admin?(persona_id, page) do
        "%#{input}%"
        |> Accounts.search_non_members(page.id) # TODO: improve search (use limit to get less results)
        |> Enum.reduce("", fn(persona, acc) ->
          acc <>
          "<div class='flexed'>" <>
            "<a href='#{link_for_persona(persona)}' class='link truncated-string'>"<>
              "<img src=#{image_for_persona(persona)} class='small-image'> #{persona.name} " <>
            "</a>" <>
            "<button type='button' name='button' class='btn btn-sm main-bg' onclick=\"personaToPageAction('invite', this, '#{parse_name(page.name)}', '#{persona.id}')\">Invite person</button>" <>
          "</div>"
        end)
      end
    end

    push socket, "replace", %{elem: elem, html: html}
    {:noreply, socket}
  end

  def handle_in("load_more", params, socket) do
    case params["type"] do
      "comments" -> load_comments(params, socket)
      "messages" -> load_messages(params, socket)
      # "search_pages" -> nil
      _ -> load_articles(params, socket) # articles
    end
    {:noreply, socket}
  end

  defp load_articles(%{"dataset" => dataset, "direction" => direction, "elem_id" => elem_id, "type" => type}, socket) do
    current_persona = current_persona(socket)

    offset = String.to_integer(dataset["offset"]) + default_limit()

    [articles, template, persona] = case type do
      "index_articles"   ->
        current_persona = current_persona |> Repo.preload(:privacy)
        include_persona_artiles = current_persona.privacy.settings["see"] == "open"
        [
          Posting.articles_for_persona(current_persona, include_persona_artiles, default_limit(), offset) |> Repo.preload([:persona, :page]),
          "_article.html",
          nil
        ]
      "page_articles"    ->
        page_name = if dataset["grouped"],
          do: String.replace_prefix(elem_id, "articles_", "") |> unparse_name(),
        else: dataset["page"]

        page = Groups.get_subd_page(page_name, current_persona.id);
        [
          Posting.articles_for_pages([page.id], default_limit(), offset) |> Repo.preload([:persona]),
          "_page_article.html",
          nil
        ]
      "persona_articles" ->
        contact_ids = Groups.contact_ids_for(current_persona.id)
        persona = Accounts.get_persona!(dataset["persona"]) |> Repo.preload(:privacy)
        public_articles = not persona.id in contact_ids
        [
          Posting.persona_articles(persona.id, public_articles, default_limit(), offset),
          "_persona_article.html",
          persona
        ]
    end

    if articles == [] do
      push socket, "disable_scroll", %{elem_id: elem_id, direction: "fwd"}
    else
      html = articles
        |> Enum.reduce("", fn(article, acc) ->
          persona = if persona, do: persona, else: article.persona
          acc<>Phoenix.View.render_to_string(WorldbadgesWeb.ArticleView, template, %{article: article, current_persona: current_persona, persona: persona})
        end)
      push socket, "load_more", %{elem_id: elem_id, html: html, insert: "beforeend", offset: offset, scroll_fwd: "true"}
    end
  end

  defp load_comments(%{"dataset" => dataset, "direction" => direction, "elem_id" => elem_id, "scroll_top" => scroll_top}, socket) do
    persona = current_persona(socket)
    article_id = dataset["articleId"]

    [comments, comment_id, insert] = if direction == "fwd" do
      comment_id = dataset["scrollForward"]
      comments = Posting.next_comments(article_id, comment_id, false, default_limit(), 0) |> Repo.preload([:persona])
      [comments, comment_id, "beforeend"]
    else
      comment_id = dataset["scrollBackward"]
      comments = Posting.previous_comments(article_id, comment_id, default_limit(), 0) |> Repo.preload([:persona])
      [comments, comment_id, "afterbegin"]
    end

    if comments == [] do
      push socket, "disable_scroll", %{elem_id: elem_id, direction: direction}
    else
      html = comments
        |> Enum.reduce("", fn(comment, acc) ->
          acc<>Phoenix.View.render_to_string(WorldbadgesWeb.CommentView, "_comment.html", %{comment: comment})
        end)
      scroll_bwd = if direction == "bwd", do: List.first(comments).id, else: dataset["scrollBackward"]
      scroll_fwd = if direction == "fwd", do: List.last(comments).id,  else: dataset["scrollForward"]
      scroll_to  = if direction == "bwd", do: "comment_#{comment_id}"

      push socket, "load_more", %{elem_id: elem_id, html: html, insert: insert, scroll_bwd: scroll_bwd, scroll_fwd: scroll_fwd, scroll_to: scroll_to}
    end
  end

  def load_messages(%{"elem_id" => elem_id, "dataset" => dataset}, socket) do
    persona = current_persona(socket)
    contact = Accounts.get_persona!(dataset["persona"])
    contact_id = contact.id
    offset = String.to_integer(dataset["offset"]) + default_limit()
    status = dataset["status"]

    messages = Posting.get_last_messages(contact_id, persona.id, default_limit(), offset)
    if messages == [] do
      push socket, "disable_scroll", %{elem_id: elem_id, direction: "bwd"}
    else
      html = messages
        |> Enum.reduce("", fn(message, acc) ->
          [sender, m_status] = if contact_id == message.persona_id, do: [contact, status], else: [persona, ""]
          "<div class='comment'>"<>Phoenix.View.render_to_string(WorldbadgesWeb.MessageView, "_message.html", persona: sender, message: message, status: m_status)<>"</div>"
          <> acc
        end)

      scroll_bwd = if m = List.last(messages), do: m.id, else: "undefined"

      push socket, "load_more", %{elem_id: elem_id, html: html, insert: "afterbegin", offset: offset, scroll_bwd: scroll_bwd, scroll_to: "message_#{dataset["scrollBackward"]}"}
    end
  end

  def handle_in("edit", dataset, socket) do
    content = dataset["content"]
    elem_id = dataset["elem_id"]
    upload  = dataset["upload"]
    [type, _, id] = String.split(elem_id, "_");

    {:ok, object} = if type == "article" do
      article = Posting.get_article!(id)

      {content, data} = get_article_data_from_content(content, upload, article.data)

      Posting.update_article(article, %{content: content, data: data})
    else
      id
      |> Posting.get_comment!()
      |> Posting.update_comment(%{content: content})
    end

    html = WorldbadgesWeb.SharedView.parse_content_unraw(object.content)
    html = if type == "article",
      do: html <> Phoenix.View.render_to_string(WorldbadgesWeb.ArticleView, "_article_data.html", article: object),
    else: html

    push socket, "edit", %{elem_id: elem_id, html: html}
    {:noreply, socket}
  end

  def handle_in("scroll_side_list", %{"offset" => offset, "search_ids" => search_ids, "type" => type, "presences" => presences}, socket) do
    persona = current_persona(socket)

    results = cond do
      type == "pages"  ->
        all_ids = Groups.subdpages_group(persona.id).ids
        ids = if search_ids == [], do: all_ids, else: Enum.filter(search_ids, &(&1 in all_ids))
        ids |> Enum.slice(offset,3) |> Groups.get_pages()
      type == "people" ->
        all_ids = persona |> Repo.preload(:contact) |> Map.fetch!(:contact) |> contact_ids()
        ids = if search_ids == [], do: all_ids, else: Enum.filter(search_ids, &(&1 in all_ids))
        ids |> Enum.slice(offset,3) |> Accounts.get_personas()
    end

    unless results in [nil, []] do
      html = if type == "pages" do
        Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_page_groups.html", pages: results)#, other_interests: false)
      else
        Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_contacts.html", contacts: results, current_persona: persona, presences: presences)
      end
      broadcast! socket, "show_groups", %{html: html, offset: offset}
    end

    {:noreply, socket}
  end

  def handle_in("side_search", %{"input" => input, "type" => type, "presences" => presences}, socket) do
    if not is_nil(input) && String.match?(input, ~r/^[a-zA-Z \d-]{2,30}$/) do
      [html, result_ids] = case type do
        "pages"   -> side_search_pages_html(input, socket)
        "people"  -> side_search_personas_html(input, presences, socket)
        # _         -> side_search_pages_html(input, socket, false)
      end

      broadcast! socket, "side_search", %{html: html, ids: result_ids}
    end

    {:noreply, socket}
  end

  def handle_in("show_box_contacts", %{"presences" => presences}, socket) do
    persona = current_persona(socket) |> Repo.preload([:contact, :missed_contact])
    contacts = Groups.contacts_for(persona)
    if contacts == [] do
      broadcast! socket, "show_box_contacts", %{html: "<b>No contacts</b>", name: nil, id: nil}
    else
      contact = List.first(contacts)
      status = if contact.image not in presences, do: "offline"
      html = writebox_contacts_html(contacts, persona, presences)

      broadcast! socket, "show_box_contacts", %{html: html}#, name: contact.name, id: contact.id}
      # TODO: remove wbox related
      # ChatModule.handle_in("chat:wchat_open",  %{"persona_id" => contact.id, "missed" => true, "status" => status}, socket)
    end

    {:noreply, socket}
  end

  def handle_in("show_box_pages", _, socket) do
    persona = current_persona(socket)
    pages = Groups.pages_for(persona.id)

    if pages == [] do
      # TODO: remove once make sure user can not unsub from all categories
      broadcast! socket, "show_box_contacts", %{html: "<b>Not subbed to any pages</b>", name: nil, id: nil}
    else
      html = Enum.reduce(pages, "", fn(page, acc) ->
        "<div><img src='#{image_for_page(page)}', class='small-image'> <a href='#' class='btn btn-sm btn-link' onclick='selectWObject(\'page_article\', \'#{page.name}\')'>#{page.name}</a></div>#{acc}"
      end)

      broadcast! socket, "show_box_pages", %{html: html}#, name: page.name, id: page.id}
    end

    {:noreply, socket}
  end

  # def handle_in("show_writebox_contacts", %{"presences" => presences}, socket) do
  #   persona = current_persona(socket) |> Repo.preload([:contact, :missed_contact])
  #   contacts = Groups.contacts_for(persona)
  #   if contacts == [] do
  #     broadcast! socket, "show_writebox_contacts", %{html: "<b>No contacts</b>", name: nil, id: nil}
  #   else
  #     contact = List.first(contacts)
  #     status = if not contact.image in presences, do: "offline"
  #     html = writebox_contacts_html(contacts, persona.missed_contact.ids, presences)
  #
  #     broadcast! socket, "show_writebox_contacts", %{html: html, name: contact.name, id: contact.id}
  #     ChatModule.handle_in("chat:wchat_open",  %{"persona_id" => contact.id, "missed" => true, "status" => status}, socket)
  #   end
  #
  #   {:noreply, socket}
  # end

  def handle_in("get_page_members", %{"page_name" => page_name, "presences" => presences}, socket) do
    persona = current_persona(socket) |> Repo.preload(:contact)
    # contacts = if page_name == "other_interests" do
    #   persona.contact.groups["0"] |> Accounts.get_personas()
    # else
    #   page = unparse_name(page_name) |> Groups.get_subd_page(persona.id)
    #   if page, do: persona.contact.groups["#{page.id}"] |> Accounts.get_personas()
    # end
    page = unparse_name(page_name) |> Groups.get_subd_page(persona.id) |> Repo.preload(:pending_persona)
    [invited, members, waiting] = if page do
      members_ids = Joins.get_persona_ids_by_page(page.id)
      members = if members_ids, do: Accounts.get_personas(members_ids)

      [invited, waiting] = if page.pending_persona do
        [Accounts.get_personas(page.pending_persona.invites),
        Accounts.get_personas(page.pending_persona.requests)]
      else
        [[], []]
      end

      [invited, members, waiting]
    end

    html = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_members.html",
      current_persona: persona,
      invited: invited,
      members: members,
      page: page,
      presences: presences,
      waiting: waiting
    )
    broadcast! socket, "show_page_members", %{html: html}#, elem_id: "contacts_"<>page_name}

    {:noreply, socket}
  end

  def handle_in("add_persona_to_contacts", %{"action" => action, "id" => id}, socket) do
    current_persona = current_persona(socket) |> Repo.preload(:contact)
    if current_persona.id != String.to_integer(id) do
      persona = Accounts.get_persona!(id) |> Repo.preload(:contact)
      add_contact = Information.get_any_add_contact(current_persona.id, persona.id)

      cond do
        action == "accept" && add_contact && add_contact.requester == persona.id -> accept_contact_request(add_contact, current_persona, persona)
        action == "block" ->
          blocked = current_persona |> Repo.preload(:blocked) |> Map.fetch!(:blocked)
          unless persona.id in blocked.ids do
            Groups.update_blocked(blocked, %{ids: [persona.id | blocked.ids]})
          end

          # remove friend requests and id from contacts
          if add_contact, do: Information.delete_add_contact(add_contact)
          remove_from_contacts(current_persona, persona)
        action == "remove" -> remove_from_contacts(current_persona, persona)
        action == "request" && add_contact -> "There is already a friend connection or request pending"
        action == "request" ->
          contact_ids = contact_ids(current_persona.contact)
          if persona.id in contact_ids do
            "There is already a friend connection or request pending"
          else
            # TODO: maybe refactor to make this smaller (similar to notify_persona method)
            Information.create_add_contact(%{requester: current_persona.id, requested: persona.id, inserted_at: Timex.now})
            event = %{
              time: Timex.now(),
              description: "New contact request",
              name: current_persona.name,
              image: current_persona.image,
              page_name: nil,
              page_image: nil,
              link: "/persona/#{current_persona.id}",
              content: nil
            }
            html = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_event.html", event: event)
            WorldbadgesWeb.Endpoint.broadcast!("room:#{persona.user_id}", "notify", %{html: html, pid: persona.id})
          end
        action == "unblock" ->
          blocked = current_persona |> Repo.preload(:blocked) |> Map.fetch!(:blocked)
          Groups.update_blocked(blocked, %{ids: (blocked.ids -- [persona.id])})
        true -> nil
      end
    end
    # TODO: broadcast friendship request; accept

    {:noreply, socket}
  end

  def handle_in("report", params, socket) do
    case params["type"] do
      "article" -> handle_in("posting:report_article", params, socket)
      "comment" -> handle_in("posting:report_comment", params, socket)
      "user"    -> report_persona(params, socket); {:noreply, socket}
      _         -> {:noreply, socket}
    end
  end

  def handle_in("persona_to_page_action", %{"action" => action, "page_name" => page_name, "persona_id" => persona_id}, socket) do
    persona = current_persona(socket)
    page = page_name
      |> unparse_name()
      |> Groups.get_page_by_name!()
      |> Repo.preload(:pending_persona)
    pending_persona = page.pending_persona

    case action do
      "accept_invite"  -> accept_invite(page, pending_persona, persona, socket)
      "accept_join"    -> accept_join(page, pending_persona, persona, persona_id, socket)
      "cancel_request" -> cancel_request(page, pending_persona, persona, socket)
      "invite"         -> invite(page, pending_persona, persona, persona_id, socket)
      "kick"           -> kick(page, persona, persona_id, socket)
      "reject_invite"  -> reject_invite(page, pending_persona, persona, socket)
      "request_join"   -> if page.free_access,
                          do:   join_page(page, persona, socket),
                          else: request_join(page, pending_persona, persona, socket)
      "reject_join"    -> reject_join(page, pending_persona, persona, persona_id, socket)
      "revoke_invite"  -> revoke_invite(page, pending_persona, persona, persona_id, socket)
      "unsubscribe"    -> unsubscribe(page, persona, socket)
      _ -> nil
    end

    {:noreply, socket}
  end

  # end of -------------------- NO MODULE METHODS ------------------------

  defp accept_contact_request(add_contact, current_persona, persona) do
    groups1 = current_persona.contact.groups
    groups2 = persona.contact.groups
    keys1 = Map.keys(groups1) |> List.flatten() |> Enum.uniq()
    keys2 = Map.keys(groups2) |> List.flatten() |> Enum.uniq()

    %{groups1: new_groups1, groups2: new_groups2} =
      Enum.reduce(keys1, %{groups1: groups1, groups2: groups2}, fn(key, acc) ->
      if key in keys2 && key != "0" do
        acc
        |> update_in([:groups1, key], &([persona.id | &1]))
        |> update_in([:groups2, key], &([current_persona.id | &1]))
      else
        acc
      end
    end)

    [new_groups1, new_groups2] = if groups1 == new_groups1 do
      new_groups1 = Map.update!(new_groups1, "0", &([persona.id | &1]))
      new_groups2 = Map.update!(new_groups2, "0", &([current_persona.id | &1]))
      [new_groups1, new_groups2]
    else
      [new_groups1, new_groups2]
    end

    notify_persona(:new_contact, nil, persona, current_persona)

    Groups.update_contact(current_persona.contact, %{groups: new_groups1})
    Groups.update_contact(persona.contact, %{groups: new_groups2})
    Information.delete_add_contact(add_contact)
  end

  defp accept_invite(page, pending_persona, persona, socket) do
    if persona.id in pending_persona.invites do
      add_persona_from_pending(page.id, persona.id, pending_persona, "invites")
      notify_admins(:new_member, page, persona)
      push socket, "replace", %{elem: "page-membership-actions", html: page_membership_actions("unsubscribe", page)}
    end
  end

  defp accept_join(page, pending_persona, persona, persona_id, socket) do
    persona_id = String.to_integer(persona_id)

    if mod_or_admin?(persona.id, page) && persona_id in pending_persona.requests do
      add_persona_from_pending(page.id, persona_id, pending_persona, "requests")
      notified_persona = Accounts.get_persona!(persona_id)
      notify_admins(:new_member, page, persona)
      notify_persona(:accepted_join_request, page, notified_persona, persona)
    end
  end

  defp add_persona_from_pending(page_id, persona_id, pending_persona, list) do
    remove_from_pending(page_id, persona_id, pending_persona, list)

    # add to page
    Joins.create_page_personas(%{page_id: page_id, persona_id: persona_id})
    subdgroup = Groups.subdpages_group(persona_id)
    new_ids_list = [page_id | subdgroup.ids] |> Groups.get_pages() |> Enum.sort_by(&String.downcase(&1.name)) |> Enum.map(&(&1.id))
    Groups.update_page_group(subdgroup, %{ids: new_ids_list})
  end

  defp invite(page, pending_persona, persona, persona_id, socket) do
    persona_id = String.to_integer(persona_id)

    if mod_or_admin?(persona.id, page) && not persona_id in pending_persona.invites do
      notified_persona = Accounts.get_persona!(persona_id)
      notify_persona(:new_join_invitation, page, notified_persona, persona)
      # {:ok, notification} = Information.create_notification(%{action: 9, link: "/page/#{parse_name(page.name)}", page_id: page.id})
      # Joins.create_notification_persona(%{notification_id: notification.id, persona_id: pending_persona.id})

      Groups.update_pending_persona(pending_persona, %{invites: [persona_id | pending_persona.invites]})
    end
  end

  defp kick(page, persona, persona_id, socket) do
    group = Groups.subdpages_group(persona_id)
    persona_id = String.to_integer(persona_id)

    if mod_or_admin?(persona.id, page) && persona_id != page.persona_id && page.id in group.ids do
      Groups.update_page_group(group, %{ids: group.ids -- [page.id]})
      Joins.delete_page_personas(page.id, persona_id)
      cond do
        persona.id in page.roles["admins"] -> Groups.update_page(page, %{roles: Map.update!(page.roles, "admins", &(&1 -- [persona_id]))})
        persona.id in page.roles["mods"] -> Groups.update_page(page, %{roles: Map.update!(page.roles, "mods", &(&1 -- [persona_id]))})
        true -> nil
      end
      # push socket, "replace", %{elem: "page-membership-actions", html: page_membership_actions("request_join", page)}
    end
  end

  defp cancel_request(page, pending_persona, persona, socket) do
    if persona.id in pending_persona.requests do
      remove_from_pending(page.id, persona.id, pending_persona, "requests")
      push socket, "replace", %{elem: "page-membership-actions", html: page_membership_actions("request_join", page)}
    end
  end

  defp current_persona?(socket) do
    !!current_persona(socket)
  end

  defp join_page(page, persona, socket) do
    subdgroup = Groups.subdpages_group(persona.id)

    if not page.id in subdgroup.ids do
      Joins.create_page_personas(%{page_id: page.id, persona_id: persona.id})
      new_ids_list = [page.id | subdgroup.ids] |> Groups.get_pages() |> Enum.sort_by(&String.downcase(&1.name)) |> Enum.map(&(&1.id))
      Groups.update_page_group(subdgroup, %{ids: new_ids_list})
      notify_admins(:new_member, page, persona)
      push socket, "replace", %{elem: "page-membership-actions", html: page_membership_actions("unsubscribe", page)}
    end
  end

  defp notification_data(action, page, persona) do
     case action do
      # :sent_recognition     -> [1, "Sent recognition", "/article/#{Enum.at(row, 6)}"]
      # :new_approval_status  -> [2, "New approval status",  "/article/#{Enum.at(row, 6)}"]
      # 3  -> ["New approval status",  "/comment/#{Enum.at(row, 6)}"]
      # 4                     -> [4] [description, content] = Enum.at(row, 7) |> String.split(":"); [description, "ad/#{Enum.at(row, 6)}", content]
      # :new_comment          -> [5, "New comment", "/comment/#{Enum.at(row, 6)}", Enum.at(row, 7)]
      :new_contact_request  -> [6, "New contact request", "/persona/#{persona.id}"]
      :new_join_request     -> page_name = if page, do: parse_name(page.name); [7, "New join request", "/page/#{page_name}"]
      :new_contact          -> [8, "New contact", "/persona/#{persona.id}"]
      :new_member           -> [9, "New member", "/persona/#{persona.id}"]
      :new_join_invitation  -> page_name = if page, do: parse_name(page.name); [10, "New join invitation", "/page/#{page_name}"]
      :accepted_join_request -> page_name = if page, do: parse_name(page.name); [11, "Accepted join request", "/page/#{page_name}"]
      # :flagged_content      -> [10, "Flagged content", Enum.at(row, 7)]
      # :removed_from_page    -> [11, "Removed from page", Enum.at(row, 7)]
    end
  end

  defp notify_admins(action, page, subject_persona) do
    [action_nr, message, link] = notification_data(action, page, subject_persona)
    {:ok, notification} = Information.create_notification(%{action: action_nr, link: link, page_id: page.id, persona_id: subject_persona.id})

    send = fn(persona_id) ->
      user_id = Accounts.get_persona!(persona_id).user_id
      html = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_join_event.html", message: message, page: page, persona: subject_persona)
      WorldbadgesWeb.Endpoint.broadcast!("room:#{user_id}", "notify", %{html: html, pid: persona_id})
      Joins.create_notification_persona(%{notification_id: notification.id, persona_id: persona_id})
    end

    for admin <- page.roles["admins"], do: send.(admin)
    for mod <- page.roles["mods"], do: send.(mod)
  end

  defp notify_persona(action, page \\ nil, notified_persona, subject_persona) do
    [action_nr, message, link] = notification_data(action, page, subject_persona)
    {:ok, notification} = Information.create_notification(%{action: action_nr, link: link, persona_id: subject_persona.id})

    # send = fn(persona) ->
      user_id = notified_persona.user_id
      [page_name, page_image] = if page, do: [page.name, page.image], else: [nil, nil]
      event = %{
        time: notification.inserted_at,
        description: message,
        name: subject_persona.name,
        image: subject_persona.image,
        page_name: nil,
        page_image: nil,
        link: link,
        content: nil
      }
      html = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_event.html", event: event)
      WorldbadgesWeb.Endpoint.broadcast!("room:#{user_id}", "notify", %{html: html, pid: notified_persona.id})
      Joins.create_notification_persona(%{notification_id: notification.id, persona_id: notified_persona.id})
    # end
    #
    # for persona <- personas, do: send.(persona)
  end

  defp reject_invite(page, pending_persona, persona, socket) do
    if persona.id in pending_persona.invites do
      remove_from_pending(page.id, persona.id, pending_persona, "invites")
      # notify_admins(page, "notify", "#{persona.name} rejected join invitation.", persona)

      push socket, "replace", %{elem: "page-membership-actions", html: page_membership_actions("request_join", page)}
    end
  end

  defp reject_join(page, pending_persona, persona, persona_id, socket) do
    persona_id = String.to_integer(persona_id)

    if mod_or_admin?(persona.id, page) && persona_id in pending_persona.requests do
      remove_from_pending(page.id, persona_id, pending_persona, "requests")
    end
  end

  defp remove_from_pending(page_id, persona_id, pending_persona, list) do
    # remove from invites/requests
    data = (pending_persona |> Map.fetch!(:"#{list}")) -- [persona_id]
    Groups.update_pending_persona(pending_persona, %{"#{list}": data})
  end

  defp remove_from_contacts(persona1, persona2) do
    filtered_ids = fn(p1, p2) ->
      Enum.reduce(p1.contact.groups, %{}, fn({group, ids}, acc) ->
        Map.put(acc, group, ids -- [p2.id])
      end)
    end
    Groups.update_contact(persona1.contact, %{groups: filtered_ids.(persona1, persona2)})
    Groups.update_contact(persona2.contact, %{groups: filtered_ids.(persona2, persona1)})
  end

  defp report_persona(%{"case_type" => case_type, "details" => case_details, "id" => id}, socket) do
    current_persona = current_persona(socket)
    persona = Accounts.get_persona!(id)

    Information.create_case(%{object_id: persona.id, persona_id: current_persona.id, type: case_type, details: case_details})
  end

  defp revoke_invite(page, pending_persona, persona, persona_id, socket) do
    persona_id = String.to_integer(persona_id)

    if mod_or_admin?(persona.id, page) && persona_id in pending_persona.invites do
      remove_from_pending(page.id, persona_id, pending_persona, "invites")
    end
  end

  defp request_join(page, pending_persona, persona, socket) do
    if not persona.id in pending_persona.requests do
      Groups.update_pending_persona(pending_persona, %{requests: [persona.id | pending_persona.requests]})
      notify_admins(:new_join_request, page, persona)
      push socket, "replace", %{elem: "page-membership-actions", html: page_membership_actions("cancel_request", page)}
    end
  end

  defp unsubscribe(page, persona, socket) do
    group = Groups.subdpages_group(persona.id)

    if page.id in group.ids && persona.id != page.persona_id do
      Groups.update_page_group(group, %{ids: group.ids -- [page.id]})
      Joins.delete_page_personas(page.id, persona.id)
      cond do
        persona.id in page.roles["admins"] -> Groups.update_page(page, %{roles: Map.update!(page.roles, "admins", &(&1 -- [persona.id]))})
        persona.id in page.roles["mods"] -> Groups.update_page(page, %{roles: Map.update!(page.roles, "mods", &(&1 -- [persona.id]))})
        true -> nil
      end
      push socket, "replace", %{elem: "page-membership-actions", html: page_membership_actions("request_join", page)}
    end
  end

  defp persona_room?(socket, subtopic) do
    persona = current_persona(socket)
    persona && persona.user_id == subtopic
  end

  defp writebox_contacts_html(contacts, persona, presences) do
    Enum.reduce(contacts, "", fn(contact, acc) ->
      status = if not contact.image in presences, do: "offline"
      # "<a class='btn btn-sm btn-link' data-chat='7' data-pid='6' href='#'>Geroge22</a>#{acc}"
      "<div class='#{status}'>
        <a href='/persona/#{contact.id}'><img class='small-image' src='#{image_for_persona(contact)}'></a>
        <a class='btn btn-sm btn-link' data-chat='#{contact.id}' data-pid='#{persona.id}' href='#'>#{contact.name}</a>
      </div>#{acc}"
      # if contact.id in missed_contact_ids do
      #   "<div class='link #{status}' data-wchat='#{contact.id}'><img src='#{image_for_persona(contact)}', class='small-image'>#{contact.name} <i class='fa fa-exclamation-circle' aria-hidden='true'></i></div>#{acc}"
      # else
      #   "#{acc}<div class='link #{status}' data-wchat='#{contact.id}'><img src='#{image_for_persona(contact)}', class='small-image'> #{contact.name}</div>"
      # end
    end)
  end
  # defp writebox_contacts_html(contacts, missed_contact_ids, presences) do
  #   Enum.reduce(contacts, "", fn(contact, acc) ->
  #     status = if not contact.image in presences, do: "offline"
  #     if contact.id in missed_contact_ids do
  #       "<div class='link #{status}' data-wchat='#{contact.id}'><img src='#{image_for_persona(contact)}', class='small-image'>#{contact.name} <i class='fa fa-exclamation-circle' aria-hidden='true'></i></div>#{acc}"
  #     else
  #       "#{acc}<div class='link #{status}' data-wchat='#{contact.id}'><img src='#{image_for_persona(contact)}', class='small-image'> #{contact.name}</div>"
  #     end
  #   end)
  # end

  defp side_search_pages_html(input, socket) do
    results = current_persona(socket).id
      |> Groups.pages_for()
      |> filter_results(input)
    result_ids = Enum.map(results, &(&1.id))

    results = results |> Enum.slice(0,3)
    html = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_page_groups.html", pages: results)#, other_interests: input != "default")

    [html, result_ids]
  end

  defp side_search_personas_html(input, presences, socket) do
    persona = current_persona(socket)
    results = persona
    |> Repo.preload(:contact)
    |> Groups.contacts_for()
    |> filter_results(input)
    |> Enum.sort_by(&String.downcase(&1.name))

    result_ids = Enum.map(results, &(&1.id))
    results = results |> Enum.slice(0,3)
    html = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_contacts.html", contacts: results, current_persona: persona, presences: presences)

    [html, result_ids]
  end

  defp filter_results(results, input) do
    filter? = input != "default"
    if filter?,
    do: Enum.filter(results, fn(result) -> Regex.compile!(input, "i") |> Regex.match?(result.name) end),
    else: results
  end

  # defp join_chat?(socket, subtopic) do
  #   subtopic_prefix? = Regex.match?(~r/^ext_/, subtopic) || Regex.match?(~r/^int_/, subtopic)
  #   room? = with {:ok, room} <- Projects.get_room_by(subtopic), do: room, else: nil
  #
  #   current_persona?(socket) && subtopic_prefix? && room?
  # end
end
