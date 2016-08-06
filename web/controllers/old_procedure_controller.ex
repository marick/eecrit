defmodule Eecrit.OldProcedureController do
  use Eecrit.Web, :controller

  alias Eecrit.OldProcedure

  def index(conn, _params) do
    procedures = OldRepo.all(OldProcedure)
    render(conn, "index.html", procedures: procedures)
  end

  def new(conn, _params) do
    changeset = OldProcedure.changeset(%OldProcedure{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"old_procedure" => old_procedure_params}) do
    changeset = OldProcedure.changeset(%OldProcedure{}, old_procedure_params)

    case OldRepo.insert(changeset) do
      {:ok, _old_procedure} ->
        conn
        |> put_flash(:info, "Old procedure created successfully.")
        |> redirect(to: old_procedure_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    old_procedure = OldRepo.get!(OldProcedure, id)
    render(conn, "show.html", old_procedure: old_procedure)
  end

  def edit(conn, %{"id" => id}) do
    old_procedure = OldRepo.get!(OldProcedure, id)
    changeset = OldProcedure.changeset(old_procedure)
    render(conn, "edit.html", old_procedure: old_procedure, changeset: changeset)
  end

  def update(conn, %{"id" => id, "old_procedure" => old_procedure_params}) do
    old_procedure = OldRepo.get!(OldProcedure, id)
    changeset = OldProcedure.changeset(old_procedure, old_procedure_params)

    case OldRepo.update(changeset) do
      {:ok, old_procedure} ->
        conn
        |> put_flash(:info, "Old procedure updated successfully.")
        |> redirect(to: old_procedure_path(conn, :show, old_procedure))
      {:error, changeset} ->
        render(conn, "edit.html", old_procedure: old_procedure, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    old_procedure = OldRepo.get!(OldProcedure, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    OldRepo.delete!(old_procedure)

    conn
    |> put_flash(:info, "Old procedure deleted successfully.")
    |> redirect(to: old_procedure_path(conn, :index))
  end
end
