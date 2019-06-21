defmodule Worldbadges.JoinsTest do
  use Worldbadges.DataCase

  alias Worldbadges.Joins

  describe "notifications_users" do
    alias Worldbadges.Joins.NotificationUser

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def notification_user_fixture(attrs \\ %{}) do
      {:ok, notification_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Joins.create_notification_user()

      notification_user
    end

    test "list_notifications_users/0 returns all notifications_users" do
      notification_user = notification_user_fixture()
      assert Joins.list_notifications_users() == [notification_user]
    end

    test "get_notification_user!/1 returns the notification_user with given id" do
      notification_user = notification_user_fixture()
      assert Joins.get_notification_user!(notification_user.id) == notification_user
    end

    test "create_notification_user/1 with valid data creates a notification_user" do
      assert {:ok, %NotificationUser{} = notification_user} = Joins.create_notification_user(@valid_attrs)
    end

    test "create_notification_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Joins.create_notification_user(@invalid_attrs)
    end

    test "update_notification_user/2 with valid data updates the notification_user" do
      notification_user = notification_user_fixture()
      assert {:ok, notification_user} = Joins.update_notification_user(notification_user, @update_attrs)
      assert %NotificationUser{} = notification_user
    end

    test "update_notification_user/2 with invalid data returns error changeset" do
      notification_user = notification_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Joins.update_notification_user(notification_user, @invalid_attrs)
      assert notification_user == Joins.get_notification_user!(notification_user.id)
    end

    test "delete_notification_user/1 deletes the notification_user" do
      notification_user = notification_user_fixture()
      assert {:ok, %NotificationUser{}} = Joins.delete_notification_user(notification_user)
      assert_raise Ecto.NoResultsError, fn -> Joins.get_notification_user!(notification_user.id) end
    end

    test "change_notification_user/1 returns a notification_user changeset" do
      notification_user = notification_user_fixture()
      assert %Ecto.Changeset{} = Joins.change_notification_user(notification_user)
    end
  end
end
