defmodule WorldbadgesWeb.GroupView do
  use WorldbadgesWeb, :view

  import WorldbadgesWeb.Shared, only: [
    image_for_persona: 1,
    image_for_page: 1,
    link_for_persona: 1,
    link_for_page: 1,
    unparse_name: 1
  ]

  def elements_list(elements, names_only, group_type, selected_elements) do
    name_string = if names_only, do: fn(name, _, _, _) -> URI.encode(name) <> "/" end, else: &WorldbadgesWeb.GroupView.image_html/4
    selected_ids = if group_type == "contacts", do: Enum.map(selected_elements, &(&1.id)), else: []

    %{elements_string: elements_string, names: names} = Enum.reduce(elements, %{elements_string: "", names: []}, fn(element, acc) ->
      [name, names] = manage_duplicate_names(element.name, acc.names)
      new_string = acc.elements_string <> name_string.(name, names, element, selected_ids)

      acc
      |> Map.put(:names, names)
      |> Map.put(:elements_string, new_string)
    end)

    string = if names_only, do: elements_string |> String.trim_trailing(),
    else: elements_string |> raw

    [string, names]
  end

  def image_html(name, names, contact, selected_ids) do
    "<div class='col-xs-3' style='margin-left: 15px;' data-name='#{URI.encode(name)}' onclick='groupToggleBadge(this)'>" <>
    "<i class='#{if contact.id in selected_ids, do: "fa fa-check-square", else: "fa fa-square-o"}' aria-hidden='true'></i> " <>
    "<img alt='#{name}' src='#{image_for_persona(contact)}' class='xs-img'>#{name}" <>
    "</div>"
  end

  def manage_duplicate_name(name, names, count \\ 0) do
    count = count + 1

    if name in names do
      name = name <> "_#{count}"
      manage_duplicate_name(name, names, count)
    else
      name
    end
  end

  def manage_duplicate_names(name, names) do
    name = manage_duplicate_name(name, names)
    names = [name | names]

    [name, names]
  end
end
