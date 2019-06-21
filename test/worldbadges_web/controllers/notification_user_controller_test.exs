defmodule WorldbadgesWeb.NotificationUserControllerTest do
  use WorldbadgesWeb.ConnCase

  alias Worldbadges.Joins

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def fixture(:notification_user) do
    {:ok, notification_user} = Joins.create_notification_user(@create_attrs)
    notification_user
  end

  describe "index" do
    test "lists all notifications_users", %{conn: conn} do
      conn = get conn, notification_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Notifications users"
    end
  end

  describe "new notification_user" do
    test "renders form", %{conn: conn} do
      conn = get conn, notification_user_path(conn, :new)
      assert html_response(conn, 200) =~ "New Notification user"
    end
  end

  describe "create notification_user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, notification_user_path(conn, :create), notification_user: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == notification_user_path(conn, :show, id)

      conn = get conn, notification_user_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Notification user"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, notification_user_path(conn, :create), notification_user: @invalid_attrs
      assert html_response(conn, 200) =~ "New Notification user"
    end
  end

  describe "edit notification_user" do
    setup [:create_notification_user]

    test "renders form for editing chosen notification_user", %{conn: conn, notification_user: notification_user} do
      conn = get conn, notification_user_path(conn, :edit, notification_user)
      assert html_response(conn, 200) =~ "Edit Notification user"
    end
  end

  describe "update notification_user" do
    setup [:create_notification_user]

    test "redirects when data is valid", %{conn: conn, notification_user: notification_user} do
      conn = put conn, notification_user_path(conn, :update, notification_user), notification_user: @update_attrs
      assert redirected_to(conn) == notification_user_path(conn, :show, notification_user)

      conn = get conn, notification_user_path(conn, :show, notification_user)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, notification_user: notification_user} do
      conn = put conn, notification_user_path(conn, :update, notification_user), notification_user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Notification user"
    end
  end

  describe "delete notification_user" do
    setup [:create_notification_user]

    test "deletes chosen notification_user", %{conn: conn, notification_user: notification_user} do
      conn = delete conn, notification_user_path(conn, :delete, notification_user)
      assert redirected_to(conn) == notification_user_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, notification_user_path(conn, :show, notification_user)
      end
    end
  end

  defp create_notification_user(_) do
    notification_user = fixture(:notification_user)
    {:ok, notification_user: notification_user}
  end
end
