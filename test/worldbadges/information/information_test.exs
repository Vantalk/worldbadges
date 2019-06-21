defmodule Worldbadges.InformationTest do
  use Worldbadges.DataCase

  alias Worldbadges.Information

  describe "consents" do
    alias Worldbadges.Information.Consent

    @valid_attrs %{consented: true}
    @update_attrs %{consented: false}
    @invalid_attrs %{consented: nil}

    def consent_fixture(attrs \\ %{}) do
      {:ok, consent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Information.create_consent()

      consent
    end

    test "list_consents/0 returns all consents" do
      consent = consent_fixture()
      assert Information.list_consents() == [consent]
    end

    test "get_consent!/1 returns the consent with given id" do
      consent = consent_fixture()
      assert Information.get_consent!(consent.id) == consent
    end

    test "create_consent/1 with valid data creates a consent" do
      assert {:ok, %Consent{} = consent} = Information.create_consent(@valid_attrs)
      assert consent.consented == true
    end

    test "create_consent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Information.create_consent(@invalid_attrs)
    end

    test "update_consent/2 with valid data updates the consent" do
      consent = consent_fixture()
      assert {:ok, consent} = Information.update_consent(consent, @update_attrs)
      assert %Consent{} = consent
      assert consent.consented == false
    end

    test "update_consent/2 with invalid data returns error changeset" do
      consent = consent_fixture()
      assert {:error, %Ecto.Changeset{}} = Information.update_consent(consent, @invalid_attrs)
      assert consent == Information.get_consent!(consent.id)
    end

    test "delete_consent/1 deletes the consent" do
      consent = consent_fixture()
      assert {:ok, %Consent{}} = Information.delete_consent(consent)
      assert_raise Ecto.NoResultsError, fn -> Information.get_consent!(consent.id) end
    end

    test "change_consent/1 returns a consent changeset" do
      consent = consent_fixture()
      assert %Ecto.Changeset{} = Information.change_consent(consent)
    end
  end

  describe "article_expiry" do
    alias Worldbadges.Information.ArticleExpiry

    @valid_attrs %{date: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{date: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{date: nil}

    def article_expiry_fixture(attrs \\ %{}) do
      {:ok, article_expiry} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Information.create_article_expiry()

      article_expiry
    end

    test "list_article_expiry/0 returns all article_expiry" do
      article_expiry = article_expiry_fixture()
      assert Information.list_article_expiry() == [article_expiry]
    end

    test "get_article_expiry!/1 returns the article_expiry with given id" do
      article_expiry = article_expiry_fixture()
      assert Information.get_article_expiry!(article_expiry.id) == article_expiry
    end

    test "create_article_expiry/1 with valid data creates a article_expiry" do
      assert {:ok, %ArticleExpiry{} = article_expiry} = Information.create_article_expiry(@valid_attrs)
      assert article_expiry.date == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_article_expiry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Information.create_article_expiry(@invalid_attrs)
    end

    test "update_article_expiry/2 with valid data updates the article_expiry" do
      article_expiry = article_expiry_fixture()
      assert {:ok, article_expiry} = Information.update_article_expiry(article_expiry, @update_attrs)
      assert %ArticleExpiry{} = article_expiry
      assert article_expiry.date == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_article_expiry/2 with invalid data returns error changeset" do
      article_expiry = article_expiry_fixture()
      assert {:error, %Ecto.Changeset{}} = Information.update_article_expiry(article_expiry, @invalid_attrs)
      assert article_expiry == Information.get_article_expiry!(article_expiry.id)
    end

    test "delete_article_expiry/1 deletes the article_expiry" do
      article_expiry = article_expiry_fixture()
      assert {:ok, %ArticleExpiry{}} = Information.delete_article_expiry(article_expiry)
      assert_raise Ecto.NoResultsError, fn -> Information.get_article_expiry!(article_expiry.id) end
    end

    test "change_article_expiry/1 returns a article_expiry changeset" do
      article_expiry = article_expiry_fixture()
      assert %Ecto.Changeset{} = Information.change_article_expiry(article_expiry)
    end
  end
end
