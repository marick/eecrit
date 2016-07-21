defmodule Eecrit.LayoutViewTest do
  use Eecrit.ConnCase, async: true
  import Phoenix.View
  import Eecrit.Router.Helpers
  alias Eecrit.LayoutView
  alias Eecrit.User

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Eecrit.Router, :browser)
      |> get("..irrelevant..")
    {:ok, %{conn: conn}}
  end

  ### The Whole View

  def render_default_layout(conn, assigns \\ []) do
    updated_assigns =
      assigns
      |> Keyword.put(:layout, {Eecrit.LayoutView, "app.html"})
      |> Keyword.put(:conn, conn)
    
    render_to_string(Eecrit.EmptyView, "index.html", updated_assigns)
  end

  test "app.html: nothing blows up", %{conn: conn} do
    content = render_default_layout(conn, current_user: nil)
    assert String.contains?(content, "Critter4Us")
  end

  ### Helpers

  defp assert_substring(safe_result, substring) do
    content = Phoenix.HTML.safe_to_string(safe_result)
    assert String.contains?(content, substring)
  end

  test "an anonymous user provokes a login link", %{conn: conn} do
    assert_substring(LayoutView.li_log_in_out(conn, nil),
                     session_path(conn, :new))
  end
  
  test "an logged-in user provokes a logout link", %{conn: conn} do
    user = %User{id: "..id.."}
    assert_substring(LayoutView.li_log_in_out(conn, user),
                     session_path(conn, :delete, user))
  end

  test "a salutation for a logged-in user", %{conn: conn} do
    user = %User{id: "..id..", display_name: "..name.."}
    assert_substring(LayoutView.li_salutation(conn, user),
                     "<li>..name..</li>")
  end

  test "anonymous users produce no salutation HTML", %{conn: conn} do
    assert LayoutView.li_salutation(conn, nil) == nil
  end
end
