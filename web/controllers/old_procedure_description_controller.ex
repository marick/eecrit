defmodule Eecrit.OldProcedureDescriptionController do
  use Eecrit.Web, :controller

  alias Eecrit.OldProcedureDescription

  def index(conn, _params) do
    procedure_descriptions = OldRepo.all(OldProcedureDescription)
    render(conn, "index.html", procedure_descriptions: procedure_descriptions)
  end

  def new(conn, _params) do
    changeset = OldProcedureDescription.changeset(%OldProcedureDescription{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"old_procedure_description" => old_procedure_description_params}) do
    changeset = OldProcedureDescription.changeset(%OldProcedureDescription{}, old_procedure_description_params)

    case OldRepo.insert(changeset) do
      {:ok, _old_procedure_description} ->
        conn
        |> put_flash(:info, "Old procedure description created successfully.")
        |> redirect(to: old_procedure_description_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    old_procedure_description = OldRepo.get!(OldProcedureDescription, id)
    render(conn, "show.html", old_procedure_description: old_procedure_description)
  end

  def edit(conn, %{"id" => id}) do
    old_procedure_description = OldRepo.get!(OldProcedureDescription, id)
    changeset = OldProcedureDescription.changeset(old_procedure_description)
    render(conn, "edit.html", old_procedure_description: old_procedure_description, changeset: changeset)
  end

  def update(conn, %{"id" => id, "old_procedure_description" => old_procedure_description_params}) do
    old_procedure_description = OldRepo.get!(OldProcedureDescription, id)
    changeset = OldProcedureDescription.changeset(old_procedure_description, old_procedure_description_params)

    case OldRepo.update(changeset) do
      {:ok, old_procedure_description} ->
        conn
        |> put_flash(:info, "Old procedure description updated successfully.")
        |> redirect(to: old_procedure_description_path(conn, :show, old_procedure_description))
      {:error, changeset} ->
        render(conn, "edit.html", old_procedure_description: old_procedure_description, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    old_procedure_description = OldRepo.get!(OldProcedureDescription, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    OldRepo.delete!(old_procedure_description)

    conn
    |> put_flash(:info, "Old procedure description deleted successfully.")
    |> redirect(to: old_procedure_description_path(conn, :index))
  end
end
