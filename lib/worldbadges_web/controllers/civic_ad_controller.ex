defmodule WorldbadgesWeb.CivicAdController do
  use WorldbadgesWeb, :controller

  # alias Worldbadges.{
  #   Groups,
  #   Posting,
  #   Posting.Ad
  # }
  #
  # import WorldbadgesWeb.Shared, only: [:upload_image: 3]
  #
  # def index(conn, _params) do
  #   ads = Posting.list_ads()
  #   render(conn, "index.html", ads: ads)
  # end
  #
  # def new(conn, _params) do
  #   persona = conn.assigns[:current_persona]
  #   changeset = Posting.change_ad(%Ad{})
  #   badges = Groups.my_badges(persona.id)
  #   general_badges = Groups.general_badges()
  #
  #   render(conn, "new.html", changeset: changeset, badges: badges, general_badges: general_badges, layout: {WorldbadgesWeb.LayoutView, "settings.html"})
  # end
  #
  # def create(conn, %{"ad" => params}) do
  #   file = params["image"]
  #   name = params["name"] |> String.trim()
  #   persona = conn.assigns[:current_persona]
  #
  #   [targets, errors] = ad_create_errors(file, name, persona, params)
  #
  #   if errors != []  do
  #     send_resp(conn, 400, Enum.join(errors, "\n"))
  #   else
  #     url = with "" <- String.trim(params["url"]), do: "#"
  #     file_name = "#{conn.assigns[:current_persona].id}-#{name}.jpg"
  #
  #     ad_params = %{name: name, image: file_name, url: url, targets: targets, persona_id: persona.id}
  #     result = if params["civic"] == "true",
  #       do: Posting.create_civic_ad(ad_params),
  #       else: Posting.create_ad(ad_params)
  #
  #     case result do
  #       {:ok, ad} ->
  #         upload_image(:ad, file.path, file_name)
  #         send_resp(conn, 200, "")
  #       {:error, %Ecto.Changeset{} = changeset} ->
  #         errors = Enum.map(changeset.errors, fn({field, error}) ->
  #           "#{field} #{elem(error, 0)}" |> String.capitalize()
  #         end)
  #         |> Enum.join(",")
  #
  #         send_resp(conn, 400, errors)
  #     end
  #   end
  # end
  #
  # def show(conn, %{"name" => name}) do
  #   persona = conn.assigns[:current_persona]
  #   ad = Posting.get_civic_ad(name, persona.id)
  #   render(conn, "show.html", ad: ad, pages: Worldbadges.Groups.pages_for(persona.id), layout: {WorldbadgesWeb.LayoutView, "page.html"})
  # end
  #
  # def edit(conn, %{"id" => id}) do
  #   persona = conn.assigns[:current_persona]
  #   ad = Posting.get_ad!(id)
  #   changeset = Posting.change_ad(ad)
  #   badges = Groups.my_badges(persona.id)
  #   general_badges = Groups.general_badges()
  #
  #   render(conn, "edit.html", ad: ad, changeset: changeset, badges: badges, general_badges: general_badges, layout: {WorldbadgesWeb.LayoutView, "settings.html"})
  # end
  #
  # def update(conn, %{"id" => id, "ad" => ad_params}) do
  #   ad = Posting.get_ad!(id)
  #
  #   case Posting.update_ad(ad, ad_params) do
  #     {:ok, ad} ->
  #       conn
  #       |> put_flash(:info, "Ad updated successfully.")
  #       |> redirect(to: ad_path(conn, :show, ad))
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", ad: ad, changeset: changeset)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   ad = Posting.get_ad!(id)
  #   {:ok, _ad} = Posting.delete_ad(ad)
  #
  #   conn
  #   |> put_flash(:info, "Ad deleted successfully.")
  #   |> redirect(to: ad_path(conn, :index))
  # end
  #
  # defp ad_create_errors(file, name, persona, params) do
  #   errors = if file == nil, do: ["No image uploaded"], else: []
  #   #TODO Disallow other file type uploads from Plug.Upload
  #   errors = if errors == [] && not file.content_type in ["image/jpeg", "image/png"], do: ["Only jpg or png image formats allowed" | errors], else: errors
  #   errors = if errors == [] && String.length(file.filename) > 30, do: ["File name too long. Maximum 30 characters permitted" | errors], else: errors
  #   errors = if errors == [] && not String.match?(file.filename, ~r/^[a-zA-Z \d-]*\.((jpeg)|(jpg)|(png))$/), do: ["File name can only contain spaces, numbers, letters, hiphens and underscores" | errors], else: errors
  #
  #   errors = if name == "", do: ["Name can't be blank" | errors], else: errors
  #   errors = if not String.match?(name, ~r/^[a-zA-Z \d-]{2,30}$/), do: ["Name can only contain spaces, numbers, letters and hiphens and must be at least 2 characters long" | errors], else: errors
  #
  #   errors = cond do
  #     params["civic"] == "true" && Posting.get_civic_ad(name, persona.id) -> ["You already have an ad with this name" | errors]
  #     params["civic"] == "false" && Posting.get_ad(name, persona.id) -> ["You already have an ad with this name" | errors]
  #     true -> errors
  #   end
  #
  #   [targets, errors] = cond do
  #     params["civic"] == "false" && params["ids"] == "" ->
  #       errors = ["No target interests selected" | errors]
  #       [nil, errors]
  #     params["civic"] == "false" && params["ids"] != "" ->
  #       targets = params["ids"] |> String.split(",") |> Enum.map(fn(id) -> String.to_integer(id) end)
  #       general_pages_ids = Worldbadges.Groups.generalpages_group().ids
  #       errors = if Enum.any?(targets, fn(id) -> not id in general_pages_ids end), do: ["No target interests selected" | errors], else: errors
  #
  #       [targets, errors]
  #     params["civic"] == "true" -> [nil, errors]
  #   end
  # end

end
