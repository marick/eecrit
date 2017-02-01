defmodule Eecrit.ReportControllerTest do
  use Eecrit.ConnCase

  # @valid_attrs %{is_admin: true, is_superuser: true, name: "some content"}
  # @invalid_attrs %{name: ""}
  # @intended_for "admin"

  ### Authorization

  @tag accessed_by: "user"
  test "anyone less than admin does not have access", %{conn: conn} do
    conn = get conn, report_path(conn, :animal_use)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  @tag accessed_by: "anonymous"
  test "that includes someone not logged in", %{conn: conn} do
    conn = get conn, report_path(conn, :animal_use)
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
