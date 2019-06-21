defmodule WorldbadgesWeb.LayoutView do
  use WorldbadgesWeb, :view

  def data(persona) do
    persona = persona |> Worldbadges.Repo.preload([:style, :privacy])
    [
      persona.style.settings["color"],
      persona.style.settings["bg"],
      (persona.privacy.settings["notifications"] == "connected")
    ]
  end
end
