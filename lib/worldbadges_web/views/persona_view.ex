defmodule WorldbadgesWeb.PersonaView do
  use WorldbadgesWeb, :view

  import WorldbadgesWeb.Shared, only: [image_for_persona: 1, image_for_badge: 1, is_mobile?: 1, link_for_persona: 1]

  def selected?(badge, persona_badges) do
    if badge.id in persona_badges, do: "main-bg"
  end

  def badge_list(badges) do
    if badges == [] do
      nil
    else
      Enum.reduce(badges, "", fn(badge, acc) -> "<img src='#{image_for_badge(badge)}' class='small-badge'>" <> acc end)
    end
  end
end
