defmodule Eecrit.OldProcedureDescriptionControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldProcedureDescription
  @valid_attrs %{animal_kind: "some content", description: "some content"}
  @invalid_attrs %{}

  @tag accessed_by: "admin"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, old_procedure_description_path(conn, :index)
    assert html_response(conn, 200) =~ "Procedure descriptions"
  end

  @tag accessed_by: "admin"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, old_procedure_description_path(conn, :new)
    assert html_response(conn, 200) =~ "New procedure description"
  end

  @tag accessed_by: "admin"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, old_procedure_description_path(conn, :create), old_procedure_description: @valid_attrs
    assert redirected_to(conn) == old_procedure_description_path(conn, :index)
    assert OldRepo.get_by(OldProcedureDescription, @valid_attrs)
  end

  @tag accessed_by: "admin"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, old_procedure_description_path(conn, :create), old_procedure_description: @invalid_attrs
    assert html_response(conn, 200) =~ "New procedure description"
  end

  @tag accessed_by: "admin"
  test "shows chosen resource", %{conn: conn} do
    old_procedure_description = OldRepo.insert! %OldProcedureDescription{}
    conn = get conn, old_procedure_description_path(conn, :show, old_procedure_description)
    assert html_response(conn, 200) =~ "Show procedure description"
  end

  @tag accessed_by: "admin"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_procedure_description_path(conn, :show, -1)
    end
  end

  @tag accessed_by: "admin"
  test "renders form for editing chosen resource", %{conn: conn} do
    old_procedure_description = OldRepo.insert! %OldProcedureDescription{}
    conn = get conn, old_procedure_description_path(conn, :edit, old_procedure_description)
    assert html_response(conn, 200) =~ "Edit procedure description"
  end

  @tag accessed_by: "admin"
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    old_procedure_description = OldRepo.insert! %OldProcedureDescription{}
    conn = put conn, old_procedure_description_path(conn, :update, old_procedure_description), old_procedure_description: @valid_attrs
    assert redirected_to(conn) == old_procedure_description_path(conn, :show, old_procedure_description)
    assert OldRepo.get_by(OldProcedureDescription, @valid_attrs)
  end

  @tag accessed_by: "admin"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    old_procedure_description = OldRepo.insert! %OldProcedureDescription{}
    conn = put conn, old_procedure_description_path(conn, :update, old_procedure_description), old_procedure_description: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit procedure description"
  end

  @tag accessed_by: "admin"
  test "deletes chosen resource", %{conn: conn} do
    old_procedure_description = OldRepo.insert! %OldProcedureDescription{}
    conn = delete conn, old_procedure_description_path(conn, :delete, old_procedure_description)
    assert redirected_to(conn) == old_procedure_description_path(conn, :index)
    refute OldRepo.get(OldProcedureDescription, old_procedure_description.id)
  end
end
