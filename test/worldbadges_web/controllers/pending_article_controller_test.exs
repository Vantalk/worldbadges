defmodule WorldbadgesWeb.PendingArticleControllerTest do
  use WorldbadgesWeb.ConnCase

  alias Worldbadges.Posting

  @create_attrs %{content: "some content", image: "some image"}
  @update_attrs %{content: "some updated content", image: "some updated image"}
  @invalid_attrs %{content: nil, image: nil}

  def fixture(:pending_article) do
    {:ok, pending_article} = Posting.create_pending_article(@create_attrs)
    pending_article
  end

  describe "index" do
    test "lists all pending_articles", %{conn: conn} do
      conn = get conn, pending_article_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Pending articles"
    end
  end

  describe "new pending_article" do
    test "renders form", %{conn: conn} do
      conn = get conn, pending_article_path(conn, :new)
      assert html_response(conn, 200) =~ "New Pending article"
    end
  end

  describe "create pending_article" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, pending_article_path(conn, :create), pending_article: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == pending_article_path(conn, :show, id)

      conn = get conn, pending_article_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Pending article"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, pending_article_path(conn, :create), pending_article: @invalid_attrs
      assert html_response(conn, 200) =~ "New Pending article"
    end
  end

  describe "edit pending_article" do
    setup [:create_pending_article]

    test "renders form for editing chosen pending_article", %{conn: conn, pending_article: pending_article} do
      conn = get conn, pending_article_path(conn, :edit, pending_article)
      assert html_response(conn, 200) =~ "Edit Pending article"
    end
  end

  describe "update pending_article" do
    setup [:create_pending_article]

    test "redirects when data is valid", %{conn: conn, pending_article: pending_article} do
      conn = put conn, pending_article_path(conn, :update, pending_article), pending_article: @update_attrs
      assert redirected_to(conn) == pending_article_path(conn, :show, pending_article)

      conn = get conn, pending_article_path(conn, :show, pending_article)
      assert html_response(conn, 200) =~ "some updated content"
    end

    test "renders errors when data is invalid", %{conn: conn, pending_article: pending_article} do
      conn = put conn, pending_article_path(conn, :update, pending_article), pending_article: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Pending article"
    end
  end

  describe "delete pending_article" do
    setup [:create_pending_article]

    test "deletes chosen pending_article", %{conn: conn, pending_article: pending_article} do
      conn = delete conn, pending_article_path(conn, :delete, pending_article)
      assert redirected_to(conn) == pending_article_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, pending_article_path(conn, :show, pending_article)
      end
    end
  end

  defp create_pending_article(_) do
    pending_article = fixture(:pending_article)
    {:ok, pending_article: pending_article}
  end
end
