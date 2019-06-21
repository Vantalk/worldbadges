defmodule Worldbadges.GroupsTest do
  use Worldbadges.DataCase

  alias Worldbadges.Groups

  describe "pending_users" do
    alias Worldbadges.Groups.PendingUser

    @valid_attrs %{ids: []}
    @update_attrs %{ids: []}
    @invalid_attrs %{ids: nil}

    def pending_user_fixture(attrs \\ %{}) do
      {:ok, pending_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Groups.create_pending_user()

      pending_user
    end

    test "list_pending_users/0 returns all pending_users" do
      pending_user = pending_user_fixture()
      assert Groups.list_pending_users() == [pending_user]
    end

    test "get_pending_user!/1 returns the pending_user with given id" do
      pending_user = pending_user_fixture()
      assert Groups.get_pending_user!(pending_user.id) == pending_user
    end

    test "create_pending_user/1 with valid data creates a pending_user" do
      assert {:ok, %PendingUser{} = pending_user} = Groups.create_pending_user(@valid_attrs)
      assert pending_user.ids == []
    end

    test "create_pending_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_pending_user(@invalid_attrs)
    end

    test "update_pending_user/2 with valid data updates the pending_user" do
      pending_user = pending_user_fixture()
      assert {:ok, pending_user} = Groups.update_pending_user(pending_user, @update_attrs)
      assert %PendingUser{} = pending_user
      assert pending_user.ids == []
    end

    test "update_pending_user/2 with invalid data returns error changeset" do
      pending_user = pending_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.update_pending_user(pending_user, @invalid_attrs)
      assert pending_user == Groups.get_pending_user!(pending_user.id)
    end

    test "delete_pending_user/1 deletes the pending_user" do
      pending_user = pending_user_fixture()
      assert {:ok, %PendingUser{}} = Groups.delete_pending_user(pending_user)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_pending_user!(pending_user.id) end
    end

    test "change_pending_user/1 returns a pending_user changeset" do
      pending_user = pending_user_fixture()
      assert %Ecto.Changeset{} = Groups.change_pending_user(pending_user)
    end
  end
end
