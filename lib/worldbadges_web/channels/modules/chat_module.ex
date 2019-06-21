defmodule WorldbadgesWeb.ChatModule do
  use WorldbadgesWeb, :channel

  import WorldbadgesWeb.ChannelsShared, only: [current_persona: 1, persona_id: 1]
  import WorldbadgesWeb.Shared, only: [contact_ids: 1, default_limit: 0, urlify: 1]

  alias Worldbadges.{
    Accounts,
    Groups,
    Posting,
    Repo
  }
  alias WorldbadgesWeb.{CommentView, MessageView}

  # -------------------------- HANDLE INFO METHODS ----------------------------

  def handle_info({:chat, params}, socket) do
    # socket = socket |> send_recent_messages()

    {:noreply, socket}
  end

  # end of ------------------- HANDLE INFO METHODS ----------------------------

  # --------------------------- HANDLE IN METHODS -----------------------------

  def handle_in("chat:create", %{"persona_id" => contact_id, "pid" => pid, "presences" => presences}, socket) do
    persona_id = persona_id(socket)
    # TODO maybe create a Accounts.get_sibling_persona method

    persona = if persona_id == pid do
      Accounts.get_persona!(pid)
    else
      current_persona = Accounts.get_persona!(persona_id)
      persona = Accounts.get_persona!(pid)
      if current_persona.user_id == persona.user_id, do: persona
    end
    |> Repo.preload([:contact, :missed_contact])

    contact_id = String.to_integer(contact_id)
    contact = Accounts.get_persona!(contact_id)

    if contact_id in contact_ids(persona.contact) do
      Groups.update_missed_contact(persona.missed_contact, %{ids: persona.missed_contact.ids -- [contact_id]})
      status = if contact.image in presences, do: "", else: "offline"
      messages = Posting.get_last_messages(contact_id, persona.id, default_limit(), 0)
      messages_html = messages
        |> Enum.reduce("", fn(message, acc) ->
          [sender, m_status] = if contact.id == message.persona_id, do: [contact, status], else: [persona, ""]
          "<div class='comment'>"<>Phoenix.View.render_to_string(MessageView, "_message.html", persona: sender, message: message, status: m_status)<>"</div>"
          <> acc
        end)
      scroll_bwd = if m = List.last(messages), do: m.id, else: "true"
      html = Phoenix.View.render_to_string(WorldbadgesWeb.SharedView, "chat_box.html", contact: contact, status: status, scroll_bwd: scroll_bwd)

      broadcast! socket, "chat:create", %{html: html, messages_html: messages_html, id: contact_id}
    end

    {:noreply, socket}
  end

  def handle_in("chat:get_events", params, socket) do
    persona  = current_persona(socket)
    personas = Accounts.get_personas_by_user(persona.user_id, []) |> Repo.preload(:missed_contact)
    persona  = if params["persona_id"],
               do: Enum.find(personas, &(&1.id == params["persona_id"])),
               else: Enum.find(personas, &(&1.id == persona.id))
    personas = [persona | (personas -- [persona])]

    broadcast! socket, "show_events", WorldbadgesWeb.SharedView.render("chat_events", %{persona: persona, personas: personas})

    {:noreply, socket}
  end

  def handle_in("chat:message_create", %{"content" => content, "recipient_id" => recipient_id, "group_chat" => group_chat, "log_time" => log_time} = params, socket) do
    persona = current_persona(socket) |> Repo.preload(:contact)
    if group_chat == "true" do
      # TODO
      nil
    else
      contact = Accounts.get_persona!(recipient_id) |> Repo.preload(:missed_contact)
      # TODO: allow to be contacted if settings > allow non contacts to contact me
      if contact.id in contact_ids(persona.contact) do
        {:ok, message} = case log_time do
          "1 day" -> create_message(params, contact.id, persona.id, 1)
          "1 month" -> create_message(params, contact.id, persona.id, 30)
          _ -> {:ok, %{id: nil, content: content}}
        end
        unless persona.id in contact.missed_contact.ids do
          Groups.update_missed_contact(contact.missed_contact, %{ids: [persona.id | contact.missed_contact.ids]})
        end

        html = Phoenix.View.render_to_string(MessageView, "_message.html", persona: persona, message: message, status: "")
        broadcast! socket, "chat:message_create", %{html: html, id: recipient_id}
        WorldbadgesWeb.Endpoint.broadcast "room:#{contact.user_id}", "chat:message_create", %{
          html: html,
          id: persona.id,
          pid: contact.id,
          name: persona.name,
          image: persona.image
        }
      end
    end

    {:noreply, socket}
  end

  # def handle_in("chat:wchat_open", %{"persona_id" => persona_id, "missed" => missed, "status" => status}, socket) do
  def handle_in("chat:wchat_open", %{"persona_id" => persona_id, "status" => status}, socket) do
    persona = current_persona(socket) |> Repo.preload(:missed_contact)
    contact = Accounts.get_persona(persona_id)
    if contact do
      messages = Posting.get_last_messages(contact.id, persona.id, default_limit(), 0)
      html = messages
        |> Enum.reduce("", fn(message, acc) ->
          [sender, m_status] = if contact.id == message.persona_id, do: [contact, status], else: [persona, ""]
          "<div class='comment'>"<>Phoenix.View.render_to_string(MessageView, "_message.html", persona: sender, message: message, status: m_status)<>"</div>"
          <> acc
        end)

      scroll_bwd = if m = List.last(messages), do: m.id, else: "undefined"
      title = "Write message to #{contact.name}"

      broadcast! socket, "chat:wchat_open", %{html: html, id: persona_id, scroll_bwd: scroll_bwd, status: status, title: title}
      # if missed do
        Groups.update_missed_contact(persona.missed_contact, %{ids: persona.missed_contact.ids -- [contact.id]})
      # end
    end

    {:noreply, socket}
  end

  # end of -------------------- HANDLE IN METHODS -----------------------------

  defp create_message(params, contact_id, persona_id, days) do
    Posting.create_message(%{content: params["content"], recipient_id: contact_id, group_chat: params["group_chat"], persona_id: persona_id, expiry_at: Timex.shift(Timex.now, days: days)})
  end

  defp current_persona_id(socket) do
    socket.assigns.guardian_default_claims["aud"] |> String.split(":") |> List.last
  end
end
