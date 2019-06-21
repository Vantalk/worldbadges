defmodule WorldbadgesWeb.DeleteTaskController do
  use WorldbadgesWeb, :controller

  alias Worldbadges.Operations
  alias Worldbadges.Operations.DeleteTask

  def index(conn, _params) do
    delete_tasks = Operations.list_delete_tasks()
    render(conn, "index.html", delete_tasks: delete_tasks)
  end

  def new(conn, _params) do
    changeset = Operations.change_delete_task(%DeleteTask{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"delete_task" => delete_task_params}) do
    case Operations.create_delete_task(delete_task_params) do
      {:ok, delete_task} ->
        conn
        |> put_flash(:info, "Delete task created successfully.")
        |> redirect(to: delete_task_path(conn, :show, delete_task))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    delete_task = Operations.get_delete_task!(id)
    render(conn, "show.html", delete_task: delete_task)
  end

  def edit(conn, %{"id" => id}) do
    delete_task = Operations.get_delete_task!(id)
    changeset = Operations.change_delete_task(delete_task)
    render(conn, "edit.html", delete_task: delete_task, changeset: changeset)
  end

  def update(conn, %{"id" => id, "delete_task" => delete_task_params}) do
    delete_task = Operations.get_delete_task!(id)

    case Operations.update_delete_task(delete_task, delete_task_params) do
      {:ok, delete_task} ->
        conn
        |> put_flash(:info, "Delete task updated successfully.")
        |> redirect(to: delete_task_path(conn, :show, delete_task))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", delete_task: delete_task, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    delete_task = Operations.get_delete_task!(id)
    {:ok, _delete_task} = Operations.delete_delete_task(delete_task)

    conn
    |> put_flash(:info, "Delete task deleted successfully.")
    |> redirect(to: delete_task_path(conn, :index))
  end
end
