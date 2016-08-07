defmodule Eecrit.OldProcedureDescriptionControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldProcedureDescription
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
    assert html_response(conn, 200) =~ "New description for exsanguination"
  end

  # CREATE

  @tag accessed_by: "admin"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    insert_old_procedure(id: @valid_attrs.procedure_id)
    conn = post conn, old_procedure_description_path(conn, :create), old_procedure_description: @valid_attrs
    assert redirected_to(conn) == old_procedure_description_path(conn, :index)
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
    assert_raise(ArgumentError, fn ->
      post conn, old_procedure_description_path(conn, :create), old_procedure_description: @bogus_attrs
    end)
  end

  # SHOW

  @tag accessed_by: "admin"
  test "shows chosen resource", %{conn: conn} do
    old_procedure_description = insert_old_procedure_description()
    conn = get conn, old_procedure_description_path(conn, :show, old_procedure_description)
    assert html_response(conn, 200) =~ "Description"
  end

  @tag accessed_by: "admin"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_procedure_description_path(conn, :show, -1)
    end
  end

  # EDIT

  @tag accessed_by: "admin", skip: true
  test "renders form for editing chosen resource", %{conn: conn} do
    old_procedure_description = insert_old_procedure_description()
    conn = get conn, old_procedure_description_path(conn, :edit, old_procedure_description)

    assert html_response(conn, 200) =~ old_procedure_description.procedure.name
  end

  # UPDATE

  @tag accessed_by: "admin", skip: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    old_procedure_description = insert_old_procedure_description()
    conn = put conn, old_procedure_description_path(conn, :update, old_procedure_description), old_procedure_description: @valid_attrs
    assert redirected_to(conn) == old_procedure_description_path(conn, :show, old_procedure_description)
    assert OldRepo.get_by(OldProcedureDescription, @valid_attrs)
  end

  @tag accessed_by: "admin", skip: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    old_procedure_description = insert_old_procedure_description()
    conn = put conn, old_procedure_description_path(conn, :update, old_procedure_description), old_procedure_description: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit #{old_procedure_description.procedure.name}"
  end

  # DELETE

  @tag accessed_by: "admin"
  test "deletes chosen resource", %{conn: conn} do
    old_procedure_description = insert_old_procedure_description()
    conn = delete conn, old_procedure_description_path(conn, :delete, old_procedure_description)
    assert redirected_to(conn) == old_procedure_description_path(conn, :index)
    refute OldRepo.get(OldProcedureDescription, old_procedure_description.id)
  end
end
