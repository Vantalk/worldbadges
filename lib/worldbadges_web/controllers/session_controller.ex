defmodule WorldbadgesWeb.SessionController do
  use WorldbadgesWeb, :controller
  import Guardian.Plug

  import WorldbadgesWeb.Shared, only: [get_persona: 1, is_mobile?: 1]

  alias Worldbadges.Accounts

  plug :scrub_params, "session" when action in ~w(create)a

  def new(conn, _) do
    current_persona = current_resource(conn)

    unless current_persona do
      render conn, "new.html"
    else
      conn |> redirect(to: page_path(conn, :index))
    end
  end

  def create(conn, %{"session" => %{"key" => key, "password" => password}}) do
    case WorldbadgesWeb.Auth.login_by_key_and_pass(conn, key, password) do
      {:ok, conn} ->
        conn
        |> redirect(to: page_path(conn, :index))
      {:error, reason, conn} ->
        conn
        |> put_flash(:error, reason)
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    Accounts.update_persona(get_persona(conn), %{left_at: Timex.now})

    conn
    |> WorldbadgesWeb.Auth.logout
    |> redirect(to: page_path(conn, :index))
  end
end
