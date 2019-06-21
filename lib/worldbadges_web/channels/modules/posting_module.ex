defmodule WorldbadgesWeb.PostingModule do
  use WorldbadgesWeb, :channel

  import WorldbadgesWeb.ChannelsShared, only: [current_persona: 1, get_article_data_from_content: 3, persona_id: 1, subtopic: 1, subtopic_group: 1]
  import WorldbadgesWeb.Shared, only: [allocate_name: 0, default_limit: 0, image_for_persona: 1, mod_or_admin?: 2, parse_name: 1, unparse_name: 1]

  alias Worldbadges.{
    Accounts,
    Features,
    Groups,
    Information,
    Joins,
    Posting,
    Repo
  }
  alias WorldbadgesWeb.CommentView

  # -------------------------- HANDLE INFO METHODS ----------------------------

  def handle_info({:page, params}, socket) do
    # socket = socket |> send_recent_messages()

    {:noreply, socket}
  end

  # end of ------------------- HANDLE INFO METHODS ----------------------------

  # --------------------------- HANDLE IN METHODS -----------------------------

  def handle_in("posting:get_events", params, socket) do
    persona  = current_persona(socket)
    personas = Accounts.get_personas_by_user(persona.user_id, [])
    persona  = if params["persona_id"],
               do: Enum.find(personas, &(&1.id == params["persona_id"])),
               else: Enum.find(personas, &(&1.id == persona.id))
    personas = [persona | (personas -- [persona])]

    broadcast! socket, "show_events", WorldbadgesWeb.SharedView.render("posting_events", %{persona: persona, personas: personas})

    {:noreply, socket}
  end

  def handle_in("posting:page_article_create", %{"content" => content, "upload" => upload, "obj_id" => page_name, "log_time" => log_time}, socket) do
    persona = current_persona(socket)
    page = page_name |> unparse_name() |> Groups.get_subd_page(persona.id)

    # TODO: search all broadcast and send to user_id + id
    if page do
      {content, data} = get_article_data_from_content(content, upload, nil)
      if page.id in Groups.generalpages_group().ids do
        Posting.create_pending_article(%{content: content, data: data, page_id: page.id, persona_id: persona.id})
        push socket, "popMessage", %{message: "Succesfully submitted. Your article is now pending approval.", status: "success"}
      else
        expiry_date = case log_time do
          "1 day"   -> Timex.shift(Timex.now, days: 1)
          "1 month" -> Timex.shift(Timex.now, days: 30)
          _ -> nil
        end

        # TODO: do not presume :ok; handle error
        {:ok, article} = Posting.create_article(%{content: content, data: data, page_id: page.id, persona_id: persona.id})
        if expiry_date, do: Information.create_article_expiry(%{date: expiry_date})
        event_link = "/page/#{parse_name(page.name)}/#{article.id}"
        article_html = Phoenix.View.render_to_string(WorldbadgesWeb.ArticleView, "_page_article.html", article: article, persona: persona, current_persona: persona)
        article_event = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_article_event.html", article: article, link: event_link, page: page, persona: persona)

        recipients = Accounts.get_personas_by_page(page.id)
        for recipient <- recipients do
          WorldbadgesWeb.Endpoint.broadcast!(
            "room:#{recipient.user_id}",
            "article:append",
            %{article_html: article_html, article_event: article_event, page_name: parse_name(page.name), pid: recipient.id, id: persona.id}
          )
        end
      end
    end

    {:noreply, socket}
  end

  def handle_in("posting:persona_article_create", %{"content" => content, "upload" => upload, "visibility" => visibility, "log_time" => log_time}, socket) do
    persona = current_persona(socket) |> Repo.preload(:contact)
    # [allow, type, name] = String.split(visibility, "_")
    # visibility = case [allow, type] do
    #   ["only", "page"]   -> [0, Groups.get_subd_page(name, persona.id).id]
    #   ["not", "page"]    -> [1, Groups.get_subd_page(name, persona.id).id]
    #
    #   ["only", "pgroup"] -> [2, Groups.get_page_group!(name, persona.id).id]
    #   ["not", "pgroup"]  -> [3, Groups.get_page_group!(name, persona.id).id]
    #
    #   ["not", "ugroup"]  -> [4, Groups.get_persona_group!(name, persona.id).id]
    #   ["only", "ugroup"] -> [5, Groups.get_persona_group!(name, persona.id).id]
    # end
    visibility = if visibility == "contacts", do: []

    expiry_date = case log_time do
      "1 day"   -> Timex.shift(Timex.now, days: 1)
      "1 month" -> Timex.shift(Timex.now, days: 30)
      _ -> nil
    end

    # TODO: do not presume :ok; handle error
    upload = if upload do
      extension = String.split(upload["name"], ".") |> List.last()
      Map.put(upload, "save_name", "#{allocate_name()}.#{extension}")
    end
    {content, data} = get_article_data_from_content(content, upload, nil)
    {:ok, article} = Posting.create_article(%{content: content, data: data, visibility: visibility, persona_id: persona.id})
    if expiry_date, do: Information.create_article_expiry(%{date: expiry_date})
    event_link = "/persona/#{persona.id}/#{article.id}"
    article_html = Phoenix.View.render_to_string(WorldbadgesWeb.ArticleView, "_persona_article.html", article: article, current_persona: persona, persona: persona)
    article_event = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_article_event.html", article: article, link: event_link, page: nil, persona: persona)

    recipients = [persona | Groups.contacts_for(persona)]
    for recipient <- recipients do
      WorldbadgesWeb.Endpoint.broadcast!(
        "room:#{recipient.user_id}",
        "article:append",
        %{article_html: article_html, article_event: article_event, page_name: nil, pid: recipient.id, id: persona.id}
      )
    end

    {:noreply, socket}
  end

  def handle_in("posting:recognize", %{"element" => element}, socket) do
    [_, article_id] = String.split(element, "_")
    article = Posting.get_article!(article_id)

    persona_id = persona_id(socket)
    if persona_interested_in_page?(persona_id, article.page_id) do
      key = "#{article.page_id}"
      receiver_id = article.persona_id
      total = cond do
        recognition = Features.get_recognition(article.id, persona_id, receiver_id) ->
          {:ok, article} = Posting.update_article(article, %{recognitions: article.recognitions - 1})
          Features.delete_recognition(recognition)

          recognition_total = Features.get_recognition_total!(receiver_id)
          json = if recognition_total.json[key] <= 1 do
            Map.delete(recognition_total.json, key)
          else
            Map.update!(recognition_total.json, key, &(&1 - 1))
          end
          Features.update_recognition_total(recognition_total, %{json: json})
          article.recognitions
        true ->
          {:ok, article} = Posting.update_article(article, %{recognitions: article.recognitions + 1})
          Features.create_recognition(%{
            persona_id: persona_id,
            receiver_id: receiver_id,
            article_id: article.id,
            page_id: article.page_id
          })

          recognition_total = Features.get_recognition_total!(receiver_id)
          json = Map.update(recognition_total.json, key, 1, &(&1 + 1))
          Features.update_recognition_total(recognition_total, %{json: json})
          # TODO: also delete interest article when article deleted by worker servers

          Information.create_interest_article(%{expiry_at: Timex.shift(Timex.now, days: 7), article_id: article.id, persona_id: persona_id})
          article.recognitions
      end

      push socket, "replace", %{elem: "recognitions_#{article.id}", html: "#{total}"}
    end

    {:noreply, socket}
  end

  def handle_in("posting:comments_show", %{"article_id" => article_id}, socket) do
    article_id = String.trim(article_id, "article_") |> String.to_integer()
    article = Posting.get_article!(article_id) |> Repo.preload(:page)
    persona = current_persona(socket)

    if can_view_article?(article, persona) do
      # TODO show a number of comments; add function comments:show_more
      comments = Posting.comments_for_article(article.id, nil, default_limit(), 0)
      scroll_bwd = if c = List.last(comments), do: c.id
      html = Enum.reduce(comments, "", fn(comment, acc) ->
         Phoenix.View.render_to_string(WorldbadgesWeb.CommentView, "_comment.html", comment: comment)<>acc
      end)

      push socket, "comments:show", %{article_id: article.id, html: html, scroll_bwd: scroll_bwd}
    end

    #
    # if view_page?(socket, article.page.name) do
    #   with
    # end
    # # get comments for article
    #
    # with {:ok, messages} <- subtopic(socket) |> Message.recent(params["offset_id"]),
    # do: push socket, "messages:show_more", WorldbadgesWeb.MessageView.render("messages", %{messages: messages, current_persona: current_persona(socket), type: "ext"})

    {:noreply, socket}
  end

  def handle_in("posting:comment_create", %{"obj_id" => article_html_id, "content" => content}, socket) do
    article = article_html_id
      |> String.trim_leading("article_")
      |> String.to_integer()
      |> Posting.get_article!()
      |> Repo.preload(:page)
    persona = current_persona(socket)

    if persona && can_access_article?(article, persona.id) do
      # TODO: 1. find better way to store huge number of personas; 2. probably use background worker for this task
      {:ok, comment} = Posting.create_comment(%{article_id: article.id, author_id: article.persona_id, content: content, page_id: article.page_id, persona_id: persona.id})
      Information.create_interest_article(%{expiry_at: Timex.shift(Timex.now, days: 7), article_id: article.id, persona_id: persona.id})
      broadcast_new_comment(article, article_html_id, comment, persona)
    else
      push socket, "popMessage", %{message: "You need to be added by the page admin to post to this page.", status: "info"}
    end

    {:noreply, socket}
  end

  def handle_in("posting:display_edit", %{"type" => type, "id" => id}, socket) do
    persona = current_persona(socket)
    object = if type == "article", do: Posting.get_article!(id), else: Posting.get_comment!(id)
    if persona.id == object.persona_id do
      html = edit_box_html(object, type)
      push socket, "display_edit", %{elem_id: "#{type}_content_#{id}", html: html}
    end

    {:noreply, socket}
  end

  def handle_in("posting:enable_article_options", %{"options_id" => options_id}, socket) do
    persona = current_persona(socket)
    article = options_id
      |> String.trim_leading("aopt_")
      |> String.to_integer()
      |> Posting.get_article!()

    if persona.id == article.persona_id do #or page admin
      push socket, "show_options", %{elem_id: options_id}
    end

    {:noreply, socket}
  end

  def handle_in("posting:enable_comment_options", %{"options_id" => options_id}, socket) do
    persona = current_persona(socket)
    comment = options_id
      |> String.trim_leading("copt_")
      |> String.to_integer()
      |> Posting.get_comment!()

    if persona.id in [comment.persona_id, comment.author_id] do #or page admin
      push socket, "show_options", %{elem_id: options_id}
    end

    {:noreply, socket}
  end

  def handle_in("posting:delete_article", %{"id" => id}, socket) do
    persona = current_persona(socket)
    article = Posting.get_article!(id) |> Repo.preload(:page)
    if persona.id == article.persona_id || mod_or_admin?(persona.id, article.page)  do
      push socket, "delete", %{elem_id: "article_"<>id}
      # broadcast_delete(article.page_id, "article_"<>id) NOTE removed because it moves while other personas viewing
      # delete_file(:file, article)
      Posting.delete_article(article)
    end

    {:noreply, socket}
  end

  def handle_in("posting:delete_comment", %{"id" => id}, socket) do
    persona = current_persona(socket)
    comment = Posting.get_comment!(id)
    if persona.id in [comment.persona_id, comment.author_id] do #or page admin
      push socket, "delete", %{elem_id: "comment_"<>id}
      # broadcast_delete(comment.page_id, "comment_"<>id) NOTE removed because it moves while other personas viewing
      Posting.delete_comment(comment)
    end

    {:noreply, socket}
  end

  def handle_in("posting:report_article", %{"id" => id, "type" => type, "details" => details}, socket) do
    persona = current_persona(socket)
    article = Posting.get_article!(id)
    if can_view_article?(article, persona) do
      Information.create_case(%{object_id: id, persona_id: persona.id, type: type, details: details})
    end

    {:noreply, socket}
  end

  def handle_in("posting:report_comment", %{"id" => id, "type" => type, "details" => details}, socket) do
    persona = current_persona(socket)
    comment = Posting.get_comment!(id) |> Repo.preload(:article)
    if can_view_article?(comment.article, persona) do
      type = String.to_integer(type) + 4
      Information.create_case(%{object_id: id, persona_id: persona.id, type: type, details: details})
    end

    {:noreply, socket}
  end

  defp broadcast_new_comment(article, article_html_id, comment, persona) do
    [page_name, page_image] = if page = article.page, do: [page.name, page.image], else: [nil, nil]
    prefix = if page_name, do: "/page/#{parse_name(page_name)}", else: "/persona/#{persona.id}"
    link = "#{prefix}/#{article.id}/#{comment.id}/#comment_#{comment.id}"

    # TODO: try to modify _comment.html to receive comment and persona to not call repo when we already know the persona
    comment = comment |> Repo.preload(:persona)
    event = %{
      time: comment.inserted_at,
      description: "New comment",
      name: persona.name,
      image: persona.image,
      page_name: page_name,
      page_image: page_image,
      link: link,
      content: comment.content
    }
    event_html   = Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_event.html", event: event)
    comment_html = Phoenix.View.render_to_string(WorldbadgesWeb.CommentView, "_comment.html", comment: comment)

    if article.page_id do
      recipients = Accounts.get_personas_by_page(article.page_id)
      for recipient <- recipients do
        unless recipient.user_id == persona.user_id do
          WorldbadgesWeb.Endpoint.broadcast!(
            "room:#{recipient.user_id}",
            "comment:append",
            %{article_html_id: article_html_id, comment_html: comment_html, event_html: event_html, page_name: parse_name(article.page.name), pid: recipient.id}
          )
        end
      end
      WorldbadgesWeb.Endpoint.broadcast!(
        "room:#{persona.user_id}",
        "comment:append",
        %{article_html_id: article_html_id, comment_html: comment_html, event_html: event_html, page_name: parse_name(article.page.name), pid: persona.id}
      )

    else
      persona = persona |> Repo.preload(:contact)
      recipients = [persona | Groups.contacts_for(persona)]
      for recipient <- recipients do
        WorldbadgesWeb.Endpoint.broadcast!(
          "room:#{recipient.user_id}",
          "comment:append",
          %{article_html_id: article_html_id, comment_html: comment_html, event_html: event_html, page_name: "", pid: recipient.id}
        )
      end
    end
  end

  # defp broadcast_delete(page_id, elem_id) do
  #   recipients = Worldbadges.Joins.get_persona_ids_by_page(page_id)
  #
  #   for recipient_id <- recipients do
  #     IO.puts "--------"
  #     IO.puts "room:#{recipient_id}"
  #     WorldbadgesWeb.Endpoint.broadcast!(
  #       "room:#{recipient_id}",
  #       "delete",
  #       %{elem_id: elem_id}
  #     )
  #   end
  # end
  #
  # def handle_in("message:new", params, socket) do
  #   current_persona  = current_persona(socket)
  #   with  {:ok, room} <- Projects.get_room_by(subtopic(socket)),
  #         {:safe, content} <- validate_content(params["content"]) do
  #
  #     message_params = params
  #     |> Map.put("content",   content)
  #     |> Map.put("subtopic",  room.subtopic)
  #     |> Map.put("persona_id",   current_persona.id)
  #     |> Map.put("room_id",   room.id)
  #
  #     changeset =
  #       %Message{}
  #       |> Message.changeset(message_params)
  #
  #     with {:ok, message} <- Repo.insert(changeset),
  #     do: broadcast! socket, "message:new", WorldbadgesWeb.MessageView.render("message", %{message: message, type: subtopic_group(socket)})
  #   end
  #
  #   {:noreply, socket}
  # end

  # end of -------------------- HANDLE IN METHODS -----------------------------

  # defp send_recent_messages(socket) do
  #   room = Repo.get_by(Room, subtopic: subtopic(socket))
  #
  #   with {:ok, messages} <- room.id |> Message.recent(),
  #   do: push socket, "messages:show_more", WorldbadgesWeb.MessageView.render("messages", %{messages: messages, current_persona: current_persona(socket), type: "ext"})
  #
  #   socket
  # end
  #
  # defp validate_content(content) do
  #   with  true <- is_binary(content),
  #         false <- content === "",
  #         {:safe, content} <- Phoenix.HTML.html_escape(content),
  #   do:   {:safe, content}
  # end

  defp can_access_article?(article, persona_id) do
    IO.puts "can_access_article"
    if page = article.page do
      page.free_access || Joins.is_member?(page.id, persona_id)
    else
      visibility = case article.visibility do
        # nil -> {:error}
        # [0, page_id]        -> persona_interested_in_page?(persona_id, page_id)
        # [1, page_id]        -> !persona_interested_in_page?(persona_id, page_id)

        # [2, page_group_id]  -> persona_interested_in_any_page?(persona_id, page_group_id)
        # [3, page_group_id]  -> !persona_interested_in_any_page?(persona_id, page_group_id)

        # [4, persona_group_id]  -> persona_in_persona_group?(persona_id, persona_group_id)
        # [5, persona_group_id]  -> !persona_in_persona_group?(persona_id, persona_group_id)
        [] -> persona_id in Groups.contact_ids_for(article.persona_id)
        _  -> true
      end
    end
  end

  defp can_edit_article?(article, persona_id) do
    IO.puts "can_edit_article"
    if page = article.page do
      page.persona_id == persona_id || persona_id in page.roles["admins"] || persona_id in page.roles["mods"]
    else
      article.persona_id == persona_id
    end
  end

  defp can_view_article?(article, persona) do
    if page = article.page do
      can_view_page?(page, persona)
    else
      persona && (can_edit_article?(article, persona.id) || can_access_article?(article, persona.id))
    end
  end

  defp can_view_page?(page, persona) do
    IO.puts "can_view_page"
    page.public_view || (persona && persona.id in Joins.is_member?(page.id, persona.id))
  end

  defp persona_interested_in_page?(persona_id, page_id) do
    IO.puts "persona_interested_in_page"
    page_id in Groups.subdpages_group(persona_id).ids
  end

  # defp persona_interested_in_any_page?(persona_id, page_group_id) do
  #   IO.puts "persona_interested_in_any_page"
  #   page_group_ids = Groups.get_page_group!(page_group_id).ids
  #   subd_pages_ids = Groups.subdpages_group(persona_id).ids
  #
  #   Enum.any?(page_group_ids, fn(page_id) -> page_id in subd_pages_ids end)
  # end

  defp persona_in_persona_group?(persona_id, persona_group_id) do
    IO.puts "persona_in_persona_group"
    persona_id in Groups.get_persona_group!(persona_group_id).ids
  end

  defp edit_box_html(object, type) do
    content = if (is_nil(object.content) || String.trim(object.content) == "") && type == "article",
        do: object.data["link"],
      else: object.content

    "<div>"<>
      "<textarea class='form-control'>#{content}</textarea>"<>
      Phoenix.View.render_to_string(WorldbadgesWeb.SharedView, "_upload.html", %{elem_id: "edit_upload_#{object.id}"}) <>
      "<button onclick='editAction(true, #{object.id})' type='button' name='button' class='btn btn-xs btn-success'><i class='fa fa-paper-plane-o' aria-hidden='true'></i> Send</button>"<>
      "<button onclick='editAction(false, #{object.id})' type='button' name='button' class='btn btn-xs btn-light'><i class='fa fa-times' aria-hidden='true'></i> Cancel</button>"<>
    "</div>"
  end

end
