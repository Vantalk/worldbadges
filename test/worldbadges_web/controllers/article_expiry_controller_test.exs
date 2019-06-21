defmodule WorldbadgesWeb.ArticleExpiryControllerTest do
  use WorldbadgesWeb.ConnCase

  alias Worldbadges.Information

  @create_attrs %{date: "2010-04-17 14:00:00.000000Z"}
  @update_attrs %{date: "2011-05-18 15:01:01.000000Z"}
  @invalid_attrs %{date: nil}

  def fixture(:article_expiry) do
    {:ok, article_expiry} = Information.create_article_expiry(@create_attrs)
    article_expiry
  end

  describe "index" do
    test "lists all article_expiry", %{conn: conn} do
      conn = get conn, article_expiry_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Article expiry"
    end
  end

  describe "new article_expiry" do
    test "renders form", %{conn: conn} do
      conn = get conn, article_expiry_path(conn, :new)
      assert html_response(conn, 200) =~ "New Article expiry"
    end
  end

  describe "create article_expiry" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, article_expiry_path(conn, :create), article_expiry: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == article_expiry_path(conn, :show, id)

      conn = get conn, article_expiry_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Article expiry"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, article_expiry_path(conn, :create), article_expiry: @invalid_attrs
      assert html_response(conn, 200) =~ "New Article expiry"
    end
  end

  describe "edit article_expiry" do
    setup [:create_article_expiry]

    test "renders form for editing chosen article_expiry", %{conn: conn, article_expiry: article_expiry} do
      conn = get conn, article_expiry_path(conn, :edit, article_expiry)
      assert html_response(conn, 200) =~ "Edit Article expiry"
    end
  end

  describe "update article_expiry" do
    setup [:create_article_expiry]

    test "redirects when data is valid", %{conn: conn, article_expiry: article_expiry} do
      conn = put conn, article_expiry_path(conn, :update, article_expiry), article_expiry: @update_attrs
      assert redirected_to(conn) == article_expiry_path(conn, :show, article_expiry)

      conn = get conn, article_expiry_path(conn, :show, article_expiry)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, article_expiry: article_expiry} do
      conn = put conn, article_expiry_path(conn, :update, article_expiry), article_expiry: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Article expiry"
    end
  end

  describe "delete article_expiry" do
    setup [:create_article_expiry]

    test "deletes chosen article_expiry", %{conn: conn, article_expiry: article_expiry} do
      conn = delete conn, article_expiry_path(conn, :delete, article_expiry)
      assert redirected_to(conn) == article_expiry_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, article_expiry_path(conn, :show, article_expiry)
      end
    end
  end

  defp create_article_expiry(_) do
    article_expiry = fixture(:article_expiry)
    {:ok, article_expiry: article_expiry}
  end
end
