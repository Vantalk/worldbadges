defmodule WorldbadgesWeb.SharedView do
  use WorldbadgesWeb, :view

  import WorldbadgesWeb.Shared, only: [image_for_page: 1, image_for_persona: 1, is_mobile?: 1, link_for_persona: 1, persona_image: 1, urlify: 1]

  # def render("chat_box", %{contact: contact}) do
  #   Phoenix.View.render_to_string(__MODULE__, "chat_box.html", contact: contact)
  # end

  def back_path(conn, back_indicator) do
    case back_indicator do
      "help"     -> shared_path(conn, :help)
      "settings" -> page_path(conn, :settings)
      "new_user" -> user_path(conn, :new)
    end
  end

  def render("chat_events", %{persona: persona, personas: personas}) do
    events_html = persona
      |> Map.fetch!(:missed_contact)
      |> Map.fetch!(:ids)
      |> Worldbadges.Information.get_chat_events(persona.id)
      |> Enum.map(fn(event) ->
        img = img_tag(persona_image(event.image), class: "small-image") |> Phoenix.HTML.Safe.to_iodata()

        "<div class='truncated-string w-100'>"<>
          "<a href='#' class='btn btn-sm btn-link' data-chat='#{event.id}' data-pid='#{persona.id}'>" <>
            "<i>#{img} #{event.name} - <span class='notify-link'>#{parse_content_unraw(event.content)}</span></i>"<>
          "</a>"<>
        "</div>"
      end)
      |> Enum.join("")
    events_html = if String.trim(events_html) == "", do: "No missed chat events", else: events_html

    personas_html = personas
      |> Enum.map(fn(persona) ->
        img_tag = img_tag(image_for_persona(persona), class: "bordered-small-image main-border") |> Phoenix.HTML.Safe.to_iodata()
        link = link(persona.name, to: "#", class: "btn btn-sm btn-link", style: "padding-left:0", onclick: "eventsBoxToggle('chat', #{persona.id})") |> Phoenix.HTML.Safe.to_iodata()
        missed_contacts = length(persona.missed_contact.ids)
        missed_contacts = if missed_contacts > 9, do: "<i class='fa fa-angle-double-up'></i>", else: to_string(missed_contacts)

        "<div>" <>
          "<span style='position: relative; right: -1em;' class='badge badge-pill badge-danger'>#{missed_contacts}</span>" <>
          "<div style='display: inline-flex;'>" <>
          "#{img_tag}#{link}" <>
        "</div></div>"
    end)
    |> Enum.join("")

    title = "Missed chat messages - #{persona.name}"

    %{events_html: events_html, personas_html: personas_html, title: title}
  end

  def render("posting_events", %{persona: persona, personas: personas}) do
    events = Worldbadges.Information.get_events(persona, 30)
    # require IEx
    # IEx.pry()
    IO.inspect events
    events_html = if length(events) == 0 do
      "No missed events"
    else
      Enum.map(events, fn(event) ->

        img = img_tag(persona_image(event.image), class: "small-image") |> Phoenix.HTML.Safe.to_iodata()
        "<div class='truncated-string w-100'>"<>
          "<a href='#{event.link}' class='btn btn-sm btn-link'>" <>
            "<i>#{img} #{event.name} - <span class='notify-link'>#{event.description}</span></i>"<>
          "</a>"<>
        "</div>"
        # Phoenix.View.render_to_string(WorldbadgesWeb.PageView, "_event.html", event: event)
      end)
      |> Enum.join("")
    end

    personas_html = personas
      |> Enum.map(fn(p) ->
        img_tag = img_tag(image_for_persona(p), class: "bordered-small-image main-border") |> Phoenix.HTML.Safe.to_iodata()
        link = link(p.name, to: "#", class: "btn btn-sm btn-link", style: "padding-left:0", onclick: "eventsBoxToggle('posting', #{p.id})") |> Phoenix.HTML.Safe.to_iodata()
        events_nr = if persona.id == p.id do
          events
        else
          Worldbadges.Information.events_total_for!(p.id)
        end
        events_nr = if events_nr > 9, do: "<i class='fa fa-angle-double-up'></i>", else: events_nr

        "<div>" <>
          "<span style='position: relative; right: -1em;' class='badge badge-pill badge-danger'>#{events_nr}</span>" <>
          "<div style='display: inline-flex;'>" <>
          "#{img_tag}#{link}" <>
        "</div></div>"
    end)
    |> Enum.join("")

    title = "Missed events - #{persona.name}"

    %{events_html: events_html, title: title, personas_html: personas_html}
  end

  def parse_content(content) do
    content |> html_escape() |> elem(1) |> urlify() |> raw()
  end

  def parse_content_unraw(content) do
    content |> html_escape() |> elem(1) |> urlify()
  end

  def writebox_pages(persona) do
    Worldbadges.Groups.pages_for(persona.id)
  end

  def writebox_persona_groups(persona) do
    Worldbadges.Groups.get_persona_groups(persona.id)
  end
end
