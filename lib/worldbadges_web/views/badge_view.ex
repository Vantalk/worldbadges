defmodule WorldbadgesWeb.BadgeView do
  use WorldbadgesWeb, :view

  import WorldbadgesWeb.Shared, only: [image_for_badge: 1, parse_name: 1]
end
