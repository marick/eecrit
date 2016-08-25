defmodule Eecrit.OldProcedureControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldProcedure
  alias Eecrit.OldProcedureDescription
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

  @tag accessed_by: "admin", skip: true
  test "lists all entries on index", %{conn: conn} do
    old_procedure = insert_old_procedure(name: "Some procedure")
    conn = get conn, old_procedure_path(conn, :index)

    html = html_response(conn, 200)
    html
    |> matches!("Procedures")
    |> allows_new!(OldProcedure, text: "Add new procedure")

    # Table row
    html
    |> allows_show!(old_procedure, text: "Show")
    |> allows_edit!(old_procedure, text: "Edit")
    |> allows_delete!(old_procedure, text: "Delete")
  end

  # NEW

  @tag accessed_by: "admin"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, old_procedure_path(conn, :new)

    html = html_response(conn, 200)
    html
    |> matches!("New procedure")
    |> allows_index!(OldProcedure, text: "Back to procedure list")
  end

  # CREATE

  @tag accessed_by: "admin"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, old_procedure_path(conn, :create), old_procedure: @valid_attrs
    created = OldRepo.get_by(OldProcedure, @valid_attrs)
    assert created
    assert redirected_to(conn) == old_procedure_path(conn, :show, created.id)
    assert flash_matches(conn, "info", ~r{PROCEDURE NAME was created})
  end

  @tag accessed_by: "admin"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, old_procedure_path(conn, :create), old_procedure: @invalid_attrs
    html = html_response(conn, 200)
    html
    |> matches!("New procedure") # back to this page.
    |> matches!("be blank")
  end

  # SHOW

  @tag accessed_by: "admin"
  test "shows chosen resource", %{conn: conn} do
    procedure = insert_old_procedure(name: "This is the chosen procedure name")
    description = insert_old_procedure_description(procedure: procedure,
                                                   description: "This is the only procedure description")
    conn = get conn, old_procedure_path(conn, :show, procedure)
    html = html_response(conn, 200)

    # What we know/can do with the procedure as a whole
    html
    |> matches!("This is the chosen procedure name")
    |> matches!("This is the only procedure description")
    |> allows_edit!(procedure, text: "Change the name or delay")

    # Working with the procedure's descriptions
    html
    |> allows_new!([OldProcedureDescription, procedure: procedure],
                   text: "Add a description")
    |> allows_edit!([description, procedure: procedure], # of our existing description
                    text: "Edit this description")
    |> allows_delete!(description, text: "Delete")

    # Available navigation away from this task
    html
    |> allows_index!(OldProcedure, text: "Show all procedures")
  end

  @tag accessed_by: "admin"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_procedure_path(conn, :show, -1)
    end
  end

  # EDIT

  @tag accessed_by: "admin", skip: true
  test "renders form for editing chosen resource", %{conn: conn} do
    procedure = insert_old_procedure(name: "Caslick's procedure")
    description = insert_old_procedure_description(
      procedure: procedure,
      description: "Procedure Instructions")
    
    conn = get conn, old_procedure_path(conn, :edit, procedure)
    html = html_response(conn, 200)
    html
    |> allows_edit!(procedure, text: "Edit Caslick&#39;s procedure")
    |> disallows_edit!(description) # Descriptions not editable here

    # Navigation away - pop back to this procedure or all procedures
    html
    |> allows_show!(procedure, "Show Caslick&#39;s procedure")
    |> allows_index!(OldProcedure, "Show all procedures")
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
