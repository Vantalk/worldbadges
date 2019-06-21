defmodule Worldbadges.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Worldbadges.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    # Personal details
    field :key,           :string, null: false

    field :pid,           :integer
    field :mid,           :string, null: false

    field :delete,        :boolean, default: false, null: false

    # Password related
    field :password,      :string, virtual: true
    field :password_hash, :string

    has_many :personas, Worldbadges.Accounts.Persona

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(key)a
  @optional_fields ~w(delete password pid mid)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(trimmed(params), @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:pid)
    |> unique_constraint(:mid)
    |> unique_constraint(:key)
  end

  # def changeset_update(id, params) do
  #   Repo.get!(__MODULE__, id)
  #   |> Ecto.Changeset.cast(trimmed(params), @required_fields ++ @optional_fields)
  #   |> hash_password
  #   |> Repo.update()
  #   |> elem(1)
  # end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> unique_constraint(:pid)
    |> unique_constraint(:mid)
    |> unique_constraint(:key)
    |> validate_length(:password, min: 6, max: 100)
    |> validate_confirmation(:password, message: "passwords do not match")
    |> validate_format(:key, ~r/^[A-Za-z0-9._]+$/, [message: "Invalid format: Only letters, numbers and the symbols . and _ are accepted"])
    |> validate_format(:pid, ~r/^[A-Za-z0-9._]+$/, [message: "Invalid format: Only letters, numbers and the symbols . and _ are accepted"])
    |> hash_password
  end

  def registration_changeset(struct, params) do
    # require IEx
    # IEx.pry()
    struct
    |> changeset(params)
    # |> unique_constraint(:email)
    |> unique_constraint(:pid)
    |> unique_constraint(:mid)
    |> unique_constraint(:key)
    |> validate_required(~w(password)a)
    |> validate_length(:password, min: 6, max: 100)
    |> validate_format(:key, ~r/^[A-Za-z0-9._]+$/, [message: "Invalid format: Only letters, numbers and the symbols . and _ are accepted"])
    # |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> hash_password
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end

  defp trimmed(params) do
    trim = fn
      field, value when field in [:password, "password"] -> value
      field, value when is_binary(value) -> String.trim(value)
      field, value when true -> value
    end

    for {field,value} <- params, into: %{}, do: {field, trim.(field,value)}
  end
end
