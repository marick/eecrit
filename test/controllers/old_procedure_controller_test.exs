defmodule Eecrit.OldProcedureControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldProcedure
  @valid_attrs %{days_delay: 42, name: "PROCEDURE NAME"}
  @invalid_attrs %{name: ""}

  ### Authorization 

  @tag accessed_by: "user"
  test "anyone less than superuser does not have access", %{conn: conn} do
    conn = get conn, old_procedure_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "that includes someone not logged in", %{conn: conn} do
    conn = get conn, old_procedure_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end


  # INDEX

  @tag accessed_by: "admin"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, old_procedure_path(conn, :index)
    assert html_response(conn, 200) =~ "Procedures"
  end

  # NEW

  @tag accessed_by: "admin"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, old_procedure_path(conn, :new)
    assert html_response(conn, 200) =~ "New procedure"
  end

  # CREATE

  @tag accessed_by: "admin"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, old_procedure_path(conn, :create), old_procedure: @valid_attrs
    created = OldRepo.get_by(OldProcedure, @valid_attrs)
    assert created
    assert redirected_to(conn) == old_procedure_path(conn, :edit, created.id)
    assert flash_matches(conn, "info", ~r{PROCEDURE NAME was created})
  end

  @tag accessed_by: "admin"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, old_procedure_path(conn, :create), old_procedure: @invalid_attrs
    assert html_response(conn, 200) =~ "New procedure"
    assert html_response(conn, 200) =~ "be blank"
  end

  # SHOW
  
  @tag accessed_by: "admin"
  test "shows chosen resource", %{conn: conn} do
    old_procedure = insert_old_procedure()
    conn = get conn, old_procedure_path(conn, :show, old_procedure)
    assert html_response(conn, 200) =~ "Procedure"
  end

  @tag accessed_by: "admin"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_procedure_path(conn, :show, -1)
    end
  end

  # EDIT

  @tag accessed_by: "admin"
  test "renders form for editing chosen resource", %{conn: conn} do
    old_procedure = insert_old_procedure(name: "Caslick's procedure")
    conn = get conn, old_procedure_path(conn, :edit, old_procedure)
    assert html_response(conn, 200) =~ "Edit Caslick&#39;s procedure"
  end

  # UPDATE

  @tag accessed_by: "admin"
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    old_procedure = insert_old_procedure()
    conn = put conn, old_procedure_path(conn, :update, old_procedure), old_procedure: @valid_attrs
    assert redirected_to(conn) == old_procedure_path(conn, :show, old_procedure)
    assert OldRepo.get_by(OldProcedure, @valid_attrs)
  end

  @tag accessed_by: "admin"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    old_procedure = insert_old_procedure(name: "Caslick's procedure")
    conn = put conn, old_procedure_path(conn, :update, old_procedure), old_procedure: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Caslick&#39;s procedure"
  end

  # DELETE
  
  @tag accessed_by: "admin"
  test "deletes chosen resource", %{conn: conn} do
    old_procedure = insert_old_procedure()
    conn = delete conn, old_procedure_path(conn, :delete, old_procedure)
    assert redirected_to(conn) == old_procedure_path(conn, :index)
    refute OldRepo.get(OldProcedure, old_procedure.id)
  end
end
