defmodule WorldbadgesWeb.AdView do
  use WorldbadgesWeb, :view

  import WorldbadgesWeb.Shared, only: [image_for_ad: 1, image_for_page: 1, parse_name: 1]

  def badges_data(badges, targets) do
    Enum.reduce(badges, %{names_string: "", badges_html: ""}, fn(badge, acc) ->
      [acc, class] = if badge.id in targets do
        [Map.update!(acc, :names_string, &(&1 <> badge.name <> "/")), "main-bg"]
      else
        [acc, nil]
      end

      acc = Map.update!(acc, :badges_html, &(
      &1 <>
      "<div class='col-xs-3'>"<>
      "<img src=#{image_for_page(badge)} class='#{class}' style='max-height: 60px;' onclick='adToggleBadge(this)' alt=#{badge.name} data-name=#{badge.name}>"<>
      "</div>"))

      acc
    end)
  end
end
