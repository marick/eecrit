defmodule Eecrit.PageControllerTest do
  use Eecrit.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200)
    assert renders_template(conn, "index.html")
  end
end
