defmodule Eecrit.OldProcedureDescriptionController do
  use Eecrit.Web, :controller
  alias Eecrit.OldProcedureDescription
  alias Eecrit.OldProcedure

  def index(conn, _params) do
    query = from pd in OldProcedureDescription,
      preload: [:procedure],
      join: p in OldProcedure, where: p.id == pd.procedure_id,
      order_by: fragment("lower(?)", p.name),
      order_by: fragment("lower(?)", pd.animal_kind)
    render(conn, "index.html", procedure_descriptions: OldRepo.all(query))
  end

  def new(conn, _params) do
    render_new(conn, OldProcedureDescription.new_action_changeset)
  end

  def create(conn, %{"old_procedure_description" => old_procedure_description_params}) do
    changeset = OldProcedureDescription.create_action_changeset(old_procedure_description_params)

    case OldRepo.insert(changeset) do
      {:ok, _old_procedure_description} ->
        conn
        |> put_flash(:info, "Procedure description was created.")
        |> redirect(to: old_procedure_description_path(conn, :index))
      {:error, changeset} ->
        render_new(conn, changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", old_procedure_description: get(id))
  end

  def edit(conn, %{"id" => id}) do
    old_procedure_description = get(id)
    changeset = OldProcedureDescription.edit_action_changeset(old_procedure_description)
    render_edit(conn, old_procedure_description, changeset)
  end

  def update(conn, %{"id" => id, "old_procedure_description" => old_procedure_description_params}) do
    old_procedure_description = get(id)
    changeset = OldProcedureDescription.update_action_changeset(old_procedure_description, old_procedure_description_params)

    case OldRepo.update(changeset) do
      {:ok, old_procedure_description} ->
        conn
        |> put_flash(:info, "Procedure description updated successfully.")
        |> redirect(to: old_procedure_description_path(conn, :show, old_procedure_description))
      {:error, changeset} ->
        render_edit(conn, old_procedure_description, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    OldRepo.delete!(get(id))

    conn
    |> put_flash(:info, "Procedure description deleted successfully.")
    |> redirect(to: old_procedure_description_path(conn, :index))
  end

  defp get(id) do
    OldRepo.get!(OldProcedureDescription, id)
    |> OldRepo.preload(:procedure)
  end

  defp render_new(conn, changeset) do
    render(conn, "new.html", changeset: changeset)
  end

  defp render_edit(conn, old_procedure_description, changeset) do
    render(conn, "edit.html", old_procedure_description: old_procedure_description, changeset: changeset)
  end
end
