defmodule Worldbadges.Operations do
  @moduledoc """
  The Operations context.
  """

  import Ecto.Query, warn: false
  alias Worldbadges.Repo

  alias Worldbadges.Operations.DeleteTask

  @doc """
  Returns the list of delete_tasks.

  ## Examples

      iex> list_delete_tasks()
      [%DeleteTask{}, ...]

  """
  def list_delete_tasks do
    Repo.all(DeleteTask)
  end

  @doc """
  Gets a single delete_task.

  Raises `Ecto.NoResultsError` if the Delete task does not exist.

  ## Examples

      iex> get_delete_task!(123)
      %DeleteTask{}

      iex> get_delete_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_delete_task!(id), do: Repo.get!(DeleteTask, id)

  @doc """
  Creates a delete_task.

  ## Examples

      iex> create_delete_task(%{field: value})
      {:ok, %DeleteTask{}}

      iex> create_delete_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_delete_task(attrs \\ %{}) do
    %DeleteTask{}
    |> DeleteTask.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a delete_task.

  ## Examples

      iex> update_delete_task(delete_task, %{field: new_value})
      {:ok, %DeleteTask{}}

      iex> update_delete_task(delete_task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_delete_task(%DeleteTask{} = delete_task, attrs) do
    delete_task
    |> DeleteTask.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DeleteTask.

  ## Examples

      iex> delete_delete_task(delete_task)
      {:ok, %DeleteTask{}}

      iex> delete_delete_task(delete_task)
      {:error, %Ecto.Changeset{}}

  """
  def remove_delete_task(type, obj_id) do
    from(d in DeleteTask, where: d.type == ^type and d.obj_id == ^obj_id)
    |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking delete_task changes.

  ## Examples

      iex> change_delete_task(delete_task)
      %Ecto.Changeset{source: %DeleteTask{}}

  """
  def change_delete_task(%DeleteTask{} = delete_task) do
    DeleteTask.changeset(delete_task, %{})
  end
end
