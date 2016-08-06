defmodule Eecrit.OldProcedureControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldProcedure
  @valid_attrs %{days_delay: 42, name: "some content"}
  @invalid_attrs %{}

  @tag accessed_by: "admin"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, old_procedure_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing procedures"
  end

  @tag accessed_by: "admin"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, old_procedure_path(conn, :new)
    assert html_response(conn, 200) =~ "New old procedure"
  end

  @tag accessed_by: "admin"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, old_procedure_path(conn, :create), old_procedure: @valid_attrs
    assert redirected_to(conn) == old_procedure_path(conn, :index)
    assert OldRepo.get_by(OldProcedure, @valid_attrs)
  end

  @tag accessed_by: "admin"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, old_procedure_path(conn, :create), old_procedure: @invalid_attrs
    assert html_response(conn, 200) =~ "New old procedure"
  end

  @tag accessed_by: "admin"
  test "shows chosen resource", %{conn: conn} do
    old_procedure = OldRepo.insert! %OldProcedure{}
    conn = get conn, old_procedure_path(conn, :show, old_procedure)
    assert html_response(conn, 200) =~ "Show old procedure"
  end

  @tag accessed_by: "admin"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_procedure_path(conn, :show, -1)
    end
  end

  @tag accessed_by: "admin"
  test "renders form for editing chosen resource", %{conn: conn} do
    old_procedure = OldRepo.insert! %OldProcedure{}
    conn = get conn, old_procedure_path(conn, :edit, old_procedure)
    assert html_response(conn, 200) =~ "Edit old procedure"
  end

  @tag accessed_by: "admin"
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    old_procedure = OldRepo.insert! %OldProcedure{}
    conn = put conn, old_procedure_path(conn, :update, old_procedure), old_procedure: @valid_attrs
    assert redirected_to(conn) == old_procedure_path(conn, :show, old_procedure)
    assert OldRepo.get_by(OldProcedure, @valid_attrs)
  end

  @tag accessed_by: "admin"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    old_procedure = OldRepo.insert! %OldProcedure{}
    conn = put conn, old_procedure_path(conn, :update, old_procedure), old_procedure: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit old procedure"
  end

  @tag accessed_by: "admin"
  test "deletes chosen resource", %{conn: conn} do
    old_procedure = OldRepo.insert! %OldProcedure{}
    conn = delete conn, old_procedure_path(conn, :delete, old_procedure)
    assert redirected_to(conn) == old_procedure_path(conn, :index)
    refute OldRepo.get(OldProcedure, old_procedure.id)
  end
end
