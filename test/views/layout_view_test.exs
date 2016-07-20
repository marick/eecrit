defmodule Eecrit.LayoutViewTest do
  use Eecrit.ConnCase, async: true
  import Phoenix.View
  import Eecrit.Router.Helpers

  def test_render(conn, assigns \\ []) do
    updated_assigns =
      assigns
      |> Keyword.put(:layout, {Eecrit.LayoutView, "app.html"})
      |> Keyword.put(:conn, conn)
    
    render_to_string(Eecrit.EmptyView, "index.html", updated_assigns)
  end

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Eecrit.Router, :browser)
      |> get("..irrelevant..")
    {:ok, %{conn: conn}}
  end

  test "an unlogged-in user provokes a login link", %{conn: conn} do
    content = test_render(conn, current_user: nil)
    assert String.contains?(content, session_path(conn, :new))
  end
  
  test "an logged-in user provokes a logout link", %{conn: conn} do
    user = %Eecrit.User{id: "..id.."}
    content = test_render(conn, current_user: user)
    assert String.contains?(content, session_path(conn, :delete, user))
  end
end
