defmodule Worldbadges.Operations.DeleteTask do
  use Ecto.Schema
  import Ecto.Changeset
  alias Worldbadges.Operations.DeleteTask


  schema "delete_tasks" do
    field :error_id, :integer#, null: false
    field :obj_id,   :integer, null: false
    field :status,   :integer
    field :type,     :string

    timestamps()
  end

  @doc false
  def changeset(%DeleteTask{} = delete_task, attrs) do
    delete_task
    |> cast(attrs, [:type, :obj_id, :status, :error_id])
    |> validate_required([:type, :obj_id])
  end
end
