defmodule WorldbadgesWeb.UserController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.{
    Accounts,
    Accounts.User,
    Groups,
    Information,
    Joins,
    Posting,
    Repo,
    Settings,
    Settings.Privacy,
    Settings.Style
  }

  alias WorldbadgesWeb.LayoutView

  # @badge_base_path "assets/static/images/base/"
  # @profile_image_path "assets/static/images/profiles/"

  import WorldbadgesWeb.Shared, only: [
    allocate_name: 0,
    get_persona: 1,
    mod_or_admin?: 2,
    upload_image: 3
  ]

  plug :scrub_params, "user" when action in [:create]

  def create(conn, %{"user" => params}) do
    if params["licence"] != "true" do
      changeset = Accounts.change_user(%User{})

      conn
      |> put_flash(:error, "You must read and consent to our Privacy&Terms to create an account.")
      |> render("new.html", changeset: changeset)
    else
      user_params = Map.put(params, "mid", UUID.uuid4(:hex))

      case Accounts.create_user(user_params) do
        {:ok, user} ->
          # name = (if params["name"], do: params["name"], else: params["key"])
          #   |> String.trim()

          name = "generated"<>allocate_name()
          image_name = allocate_name()

          persona_params = %{image: image_name, left_at: Timex.now, name: name, user_id: user.id}

          case Accounts.create_persona(persona_params) do
            {:ok, persona} ->
              upload_image(:profile, "./assets/static/images/profiles/avatar.jpg", image_name)
              
              persona_id = persona.id
              Accounts.create_persona_associated_data(persona_id)

              Accounts.update_user(user, pid: persona_id)
              {:ok, conn} = WorldbadgesWeb.Auth.login_by_key_and_pass(conn, user.key, user_params["password"])

              redirect(conn, to: persona_path(conn, :edit, persona))
          end
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "Ad deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  def delete_account(conn, _) do
    # TODO have an icon to notify the user and others that his account is up for deletion
    user = get_user(conn)
    case Worldbadges.Operations.create_delete_task(%{type: "user", obj_id: user.id}) do
      {:ok, delete_task} ->
        Accounts.update_user(user, %{delete: true})
        send_resp(conn, 200, "")
      {:error, %Ecto.Changeset{} = changeset} ->
        send_resp(conn, 400, "Operation failed. Please notify our help support.")
    end
  end

  def edit(conn, _) do
    changeset = get_user(conn) |> Accounts.change_user()
    render(conn, "edit.html", changeset: changeset, layout: {LayoutView, "page.html"})
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  # def show(conn, %{"" => }) do
    # update_cookie(conn, name)
    # current_user = conn.assigns[:current_user]
    #
    # events = Information.get_events(current_user.id, current_user.left_at, 30)
    # pages = Groups.pages_for(current_user.id)
    #
    # badge_ids = Groups.mybadges_group(current_user.id).ids
    # ad = Posting.get_random_ad(badge_ids)
    #
    # contact_ids = Groups.contacts_group_for(current_user.id).ids
    # contacts = Accounts.get_users(contact_ids)
    #
    # user = Accounts.get_user_by_!() |> Repo.preload(:privacy)
    # # TODO: enable specific articles
    # # articles = Posting.list_page_articles() |> Worldbadges.Repo.preload(:user) |> Worldbadges.Repo.preload(:badge)
    # articles = Posting.user_articles(user.id)
    # user_badges = user_badges(user, current_user, contact_ids)
    #
    # render(conn, "show.html",
    #   ad: ad,
    #   add: add(current_user, user),
    #   articles: articles,
    #   events: events,
    #   contacts: contacts,
    #   pages: pages,
    #   user: user,
    #   user_badges: user_badges,
    #   layout: {LayoutView, "page.html"}
    # )
  # end

  def reserve_account(conn, %{"months" => months}) do
    # TODO: actually reserve
    send_resp(conn, 200, "")
  end

  def revoke_account_deletion(conn, _) do
    user = get_user(conn)
    {nr_deletes, _} = Worldbadges.Operations.remove_delete_task("user", user.id)
    if nr_deletes > 0 do
      Accounts.update_user(user, %{delete: false})
      send_resp(conn, 200, "")
    else
      send_resp(conn, 400, "Account deletion was already revoked or never initiated. If you are having issues please notify our help support.")
    end
  end

  def update(conn, %{"user" => params}) do
    user = get_user(conn)

    user_params = if params["key"] == "", do: Map.delete(params, "key"), else: params
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        redirect(conn, to: shared_path(conn, :settings))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  # defp add_uuids(params) do
  #   params
  #   |> Map.put("mid", UUID.uuid4(:hex))
  #   |> Map.put("", UUID.uuid4(:hex))
  # end

  defp bg(color) do
    case color do
      "rgb(255, 174, 188)" -> "#ffdae1" #pinkish
      "purple" -> "#d1c5d0"
      "brown" -> "#d1c5c5"
      "orange" -> "#ddd4c6"
      "green" -> "#d1c5c5"
      "steelblue" -> "#accce7"
      "black" -> "#717171"
      _ -> "#d1c5c5"
    end
  end

  defp get_user(conn) do
    get_persona(conn).id |> Accounts.get_user!()
  end

end
