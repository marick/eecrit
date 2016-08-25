defmodule Eecrit.OldProcedureDescriptionControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldProcedureDescription
  alias Eecrit.OldProcedure
  @valid_attrs %{animal_kind: "bovine", description: "Some description", procedure_id: 43}
  @invalid_attrs %{animal_kind: "", procedure_id: 43}
  @bogus_attrs %{}

  ### Authorization 

  @tag accessed_by: "user"
  test "anyone less than superuser does not have access", %{conn: conn} do
    conn = get conn, old_procedure_description_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "that includes someone not logged in", %{conn: conn} do
    conn = get conn, old_procedure_description_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end


  # INDEX

  @tag accessed_by: "admin"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, old_procedure_description_path(conn, :index)
    assert html_response(conn, 200) =~ "All procedure descriptions"
  end

  # NEW

  @tag accessed_by: "admin"
  test "renders form for new resources", %{conn: conn} do
    procedure = insert_old_procedure(name: "exsanguination")
    conn = get conn, old_procedure_description_path(conn, :new, procedure: procedure.id)
    assert conn.assigns.valid_animal_kinds == OldProcedureDescription.valid_animal_kinds

    html = html_response(conn, 200)
    html
    |> matches!("New description for exsanguination")
    |> allows_show!(procedure, text: "Abandon new description and return to procedure")
  end

  # CREATE

  @tag accessed_by: "admin"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    insert_old_procedure(id: @valid_attrs.procedure_id)
    conn = post conn, old_procedure_description_path(conn, :create), old_procedure_description: @valid_attrs
    assert redirected_to(conn) == old_procedure_path(conn, :show, @valid_attrs.procedure_id)
    assert OldRepo.get_by(OldProcedureDescription, @valid_attrs)
  end

  @tag accessed_by: "admin"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    procedure = insert_old_procedure(id: @valid_attrs.procedure_id)
    conn = post conn, old_procedure_description_path(conn, :create), old_procedure_description: @invalid_attrs
    assert html_response(conn, 200) =~ "New description for #{procedure.name}"
  end

  @tag accessed_by: "admin"
  test "a missing procedure id just provokes a 500", %{conn: conn} do
    assert_exception ArgumentError do
      post conn,
        old_procedure_description_path(conn, :create),
        old_procedure_description: @bogus_attrs
    end
  end

  # SHOW

  @tag accessed_by: "admin"
  test "shows chosen resource", %{conn: conn} do
    old_procedure_description = insert_old_procedure_description()
    conn = get conn, old_procedure_description_path(conn, :show, old_procedure_description)
    html = html_response(conn, 200)
    assert html =~ "Description"

    # outgoing links
    html
    |> allows_show!(old_procedure_description.procedure, text: "View the procedure this belongs to")
    |> allows_index!(OldProcedure, text: "View all procedures")
    |> allows_index!(OldProcedureDescription, text: "View all descriptions")
  end

  @tag accessed_by: "admin"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_procedure_description_path(conn, :show, -1)
    end
  end

  # EDIT

  @tag accessed_by: "admin"
  test "renders form for editing chosen resource", %{conn: conn} do
    old_procedure_description = insert_old_procedure_description()
    conn = get conn, old_procedure_description_path(conn, :edit, old_procedure_description, procedure: old_procedure_description.procedure.id)

    assert conn.assigns.valid_animal_kinds == OldProcedureDescription.valid_animal_kinds
    html = html_response(conn, 200)
    html
    |> matches!(old_procedure_description.procedure.name)
    |> matches!(old_procedure_description.animal_kind)
    |> allows_show!(old_procedure_description.procedure, text: "Abandon change and return to procedure")
  end

  # UPDATE

  @tag accessed_by: "admin"
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    procedure = insert_old_procedure(id: @valid_attrs.procedure_id)
    old_procedure_description = insert_old_procedure_description(procedure: procedure)
    conn = put conn, old_procedure_description_path(conn, :update, old_procedure_description), old_procedure_description: @valid_attrs
    assert redirected_to(conn) == old_procedure_path(conn, :show, procedure.id)
    assert OldRepo.get_by(OldProcedureDescription, @valid_attrs)
  end

  @tag accessed_by: "admin"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    procedure = insert_old_procedure(id: @valid_attrs.procedure_id)
    old_procedure_description = insert_old_procedure_description(procedure: procedure)
    conn = put conn, old_procedure_description_path(conn, :update, old_procedure_description), old_procedure_description: @invalid_attrs
    response = html_response(conn, 200)
    # Confirm that we're back to editing.
    assert response =~ "Edit"
    assert response =~ old_procedure_description.procedure.name
    assert response =~ old_procedure_description.animal_kind
  end

  # DELETE

  @tag accessed_by: "admin"
  test "deletes chosen resource", %{conn: conn} do
    old_procedure_description = insert_old_procedure_description()
    conn = delete conn, old_procedure_description_path(conn, :delete, old_procedure_description)
    assert redirected_to(conn) == old_procedure_path(conn, :show, old_procedure_description.procedure)
    refute OldRepo.get(OldProcedureDescription, old_procedure_description.id)
  end
end
