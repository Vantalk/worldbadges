defmodule Worldbadges.PostingTest do
  use Worldbadges.DataCase

  alias Worldbadges.Posting

  describe "pending_articles" do
    alias Worldbadges.Posting.PendingArticle

    @valid_attrs %{content: "some content", image: "some image"}
    @update_attrs %{content: "some updated content", image: "some updated image"}
    @invalid_attrs %{content: nil, image: nil}

    def pending_article_fixture(attrs \\ %{}) do
      {:ok, pending_article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posting.create_pending_article()

      pending_article
    end

    test "list_pending_articles/0 returns all pending_articles" do
      pending_article = pending_article_fixture()
      assert Posting.list_pending_articles() == [pending_article]
    end

    test "get_pending_article!/1 returns the pending_article with given id" do
      pending_article = pending_article_fixture()
      assert Posting.get_pending_article!(pending_article.id) == pending_article
    end

    test "create_pending_article/1 with valid data creates a pending_article" do
      assert {:ok, %PendingArticle{} = pending_article} = Posting.create_pending_article(@valid_attrs)
      assert pending_article.content == "some content"
      assert pending_article.image == "some image"
    end

    test "create_pending_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posting.create_pending_article(@invalid_attrs)
    end

    test "update_pending_article/2 with valid data updates the pending_article" do
      pending_article = pending_article_fixture()
      assert {:ok, pending_article} = Posting.update_pending_article(pending_article, @update_attrs)
      assert %PendingArticle{} = pending_article
      assert pending_article.content == "some updated content"
      assert pending_article.image == "some updated image"
    end

    test "update_pending_article/2 with invalid data returns error changeset" do
      pending_article = pending_article_fixture()
      assert {:error, %Ecto.Changeset{}} = Posting.update_pending_article(pending_article, @invalid_attrs)
      assert pending_article == Posting.get_pending_article!(pending_article.id)
    end

    test "delete_pending_article/1 deletes the pending_article" do
      pending_article = pending_article_fixture()
      assert {:ok, %PendingArticle{}} = Posting.delete_pending_article(pending_article)
      assert_raise Ecto.NoResultsError, fn -> Posting.get_pending_article!(pending_article.id) end
    end

    test "change_pending_article/1 returns a pending_article changeset" do
      pending_article = pending_article_fixture()
      assert %Ecto.Changeset{} = Posting.change_pending_article(pending_article)
    end
  end
end
