defmodule WorldbadgesWeb.PendingUserControllerTest do
  use WorldbadgesWeb.ConnCase

  alias Worldbadges.Groups

  @create_attrs %{ids: []}
  @update_attrs %{ids: []}
  @invalid_attrs %{ids: nil}

  def fixture(:pending_user) do
    {:ok, pending_user} = Groups.create_pending_user(@create_attrs)
    pending_user
  end

  describe "index" do
    test "lists all pending_users", %{conn: conn} do
      conn = get conn, pending_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Pending users"
    end
  end

  describe "new pending_user" do
    test "renders form", %{conn: conn} do
      conn = get conn, pending_user_path(conn, :new)
      assert html_response(conn, 200) =~ "New Pending user"
    end
  end

  describe "create pending_user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, pending_user_path(conn, :create), pending_user: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == pending_user_path(conn, :show, id)

      conn = get conn, pending_user_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Pending user"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, pending_user_path(conn, :create), pending_user: @invalid_attrs
      assert html_response(conn, 200) =~ "New Pending user"
    end
  end

  describe "edit pending_user" do
    setup [:create_pending_user]

    test "renders form for editing chosen pending_user", %{conn: conn, pending_user: pending_user} do
      conn = get conn, pending_user_path(conn, :edit, pending_user)
      assert html_response(conn, 200) =~ "Edit Pending user"
    end
  end

  describe "update pending_user" do
    setup [:create_pending_user]

    test "redirects when data is valid", %{conn: conn, pending_user: pending_user} do
      conn = put conn, pending_user_path(conn, :update, pending_user), pending_user: @update_attrs
      assert redirected_to(conn) == pending_user_path(conn, :show, pending_user)

      conn = get conn, pending_user_path(conn, :show, pending_user)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, pending_user: pending_user} do
      conn = put conn, pending_user_path(conn, :update, pending_user), pending_user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Pending user"
    end
  end

  describe "delete pending_user" do
    setup [:create_pending_user]

    test "deletes chosen pending_user", %{conn: conn, pending_user: pending_user} do
      conn = delete conn, pending_user_path(conn, :delete, pending_user)
      assert redirected_to(conn) == pending_user_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, pending_user_path(conn, :show, pending_user)
      end
    end
  end

  defp create_pending_user(_) do
    pending_user = fixture(:pending_user)
    {:ok, pending_user: pending_user}
  end
end
