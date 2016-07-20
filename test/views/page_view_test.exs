defmodule Eecrit.PageViewTest do
  use Eecrit.ConnCase, async: true
  import Phoenix.View

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Eecrit.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "something appears", %{conn: conn} do
    content = render_to_string(Eecrit.PageView, "index.html", conn: conn)
    assert String.contains?(content, "Critter4Us")
  end
end
