defmodule WorldbadgesWeb.PageView do
  use WorldbadgesWeb, :view

  import WorldbadgesWeb.Shared, only: [
    admin?: 2,
    default_limit: 0,
    image_for_ad: 1,
    image_for_badge: 1,
    image_for_page: 1,
    image_for_persona: 1,
    is_mobile?: 1,
    link_for_page: 1,
    link_for_persona: 1,
    page_membership_actions: 2,
    page_image: 1,
    page_name_link: 1,
    parse_name: 1
  ]

  def image_for_event_page(event), do: page_image(event.page_image)

  def link_for_event_page(event), do: page_name_link(event.page_name)

  def link_for_event_persona(event), do: link_for_persona(event)

  def name_for_event_persona(event), do: parse_name(event.name)

  def article_placeholder(articles, member?, page, persona) do
    img_tag = img_tag("/images/logo.png", style: "width: 30px;")
    |> Phoenix.HTML.Safe.to_iodata()

    cond do
      not member? && not page.public_view ->
        "<div class='card'>
          <div class='card-body'>
            #{img_tag}
            This page requires you to be a member to view articles.
            <br>Click <a href='#' class='btn btn-sm btn-default main-color' onclick=\"personaToPageAction('request_join', this, '#{parse_name(page.name)}')\">Request join</a>
            to ask to join.
          </div>
        </div>" |> raw()

      not member? && not page.free_access ->
        "<div class='card'>
          <div class='card-body'>
            #{img_tag}
            Articles will show up here as they are posted.
            <br>Click <a href='#' class='btn btn-sm btn-default main-color' onclick=\"personaToPageAction('request_join', this, '#{parse_name(page.name)}')\">Request join</a>
            to ask to join and post articles.
          </div>
        </div>" |> raw()

      articles == [] ->
        "<div class='card'>
          <div class='card-body'>
            #{img_tag}
            Articles will show up here as they are posted.
            <br>Click <a href='#' onclick='pageBoxToggle()'><i class='fa fa-pencil-square-o' aria-hidden='true'></i></a>
            to post articles, comments and send messages.
          </div>
        </div>" |> raw()

      true -> nil
    end
  end

  def join(member?, page, persona) do
    cond do
      member? ->
        "<div id='page-membership-actions'>" <>
          page_membership_actions("unsubscribe", page) <>
        "</div>"
      page.pending_persona && persona.id in page.pending_persona.requests ->
        "<div id='page-membership-actions'>" <>
          page_membership_actions("cancel_request", page) <>
        "</div>"
      page.pending_persona && persona.id in page.pending_persona.invites ->
        "<div id='page-membership-actions'>" <>
          page_membership_actions("accept_invite", page) <>
          page_membership_actions("reject_invite", page) <>
        "</div>"
      true ->
        "<div id='page-membership-actions'>" <>
          page_membership_actions("request_join", page) <>
        "</div>"
    end
  end

end
