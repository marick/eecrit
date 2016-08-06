defmodule Eecrit.OldProcedureController do
  use Eecrit.Web, :controller
  alias Eecrit.OldProcedure

  def index(conn, _params) do
    procedures = OldRepo.all(from a in OldProcedure,
                             order_by: fragment("lower(?)", a.name))
    render(conn, "index.html", procedures: procedures)
  end

  def new(conn, _params) do
    render_new(conn, OldProcedure.new_action_changeset)
  end

  def create(conn, %{"old_procedure" => old_procedure_params}) do
    changeset = OldProcedure.create_action_changeset(old_procedure_params)

    case OldRepo.insert(changeset) do
      {:ok, old_procedure} ->
        conn
        |> put_flash(:info, "#{old_procedure.name} was created.")
        |> redirect(to: old_procedure_path(conn, :index))
      {:error, changeset} ->
        render_new(conn, changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    old_procedure = OldRepo.get!(OldProcedure, id)
    render(conn, "show.html", old_procedure: old_procedure)
  end

  def edit(conn, %{"id" => id}) do
    old_procedure = OldRepo.get!(OldProcedure, id)
    changeset = OldProcedure.edit_action_changeset(old_procedure)
    render_edit(conn, old_procedure, changeset)
  end

  def update(conn, %{"id" => id, "old_procedure" => old_procedure_params}) do
    old_procedure = OldRepo.get!(OldProcedure, id)
    changeset = OldProcedure.update_action_changeset(old_procedure, old_procedure_params)

    case OldRepo.update(changeset) do
      {:ok, old_procedure} ->
        conn
        |> put_flash(:info, "#{old_procedure.name} has been changed.")
        |> redirect(to: old_procedure_path(conn, :show, old_procedure))
      {:error, changeset} ->
        render_edit(conn, old_procedure, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    old_procedure = OldRepo.get!(OldProcedure, id)
    OldRepo.delete!(old_procedure)

    conn
    |> put_flash(:info, "Procedure deleted successfully.")
    |> redirect(to: old_procedure_path(conn, :index))
  end


  defp render_new(conn, changeset) do
    render(conn, "new.html", changeset: changeset)
  end

  defp render_edit(conn, old_procedure, changeset) do
    render(conn, "edit.html", old_procedure: old_procedure, changeset: changeset)
  end
end
