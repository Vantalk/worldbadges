defmodule Worldbadges.Repo.Migrations.CreateAddContacts do
  use Ecto.Migration

  def change do
    create table(:add_contacts, primary_key: false) do
      add :requester, :integer
      add :requested, :integer
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:add_contacts, [:requester, :requested], name: :add_contact)
  end
end
