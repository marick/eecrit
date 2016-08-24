defmodule Eecrit.LayoutViewTest do
  use Eecrit.ViewCase, async: true
  alias Eecrit.LayoutView
  alias Eecrit.User

  test "a page renders without blowing up", %{conn: conn} do
    assert render_layout(conn) =~ "Critter4Us"
  end

  describe "a navigation bar" do
    setup context = %{conn: conn} do
      html = LayoutView.navigation(conn) |> to_view_string
      assign context, html: html, user: conn.assigns.current_user
    end

    @tag accessed_by: "anonymous"
    test "the anonymous user has a login link and nothing more", %{html: html} do
      html
      |> login_allowed!
      |> no_user_information_shows!
      |> no_admin_actions!
    end

    @tag accessed_by: "user"
    test "a plain user can really only log out", %{user: user, html: html} do
      html
      |> logout_allowed!(user)
      |> user_information_shows!(user)
      |> no_admin_actions!
    end
    
    @tag accessed_by: "admin"
    test "admins have quick links to do their job", %{user: user, html: html} do
      html
      |> logout_allowed!(user)
      |> user_information_shows!(user)
      |> can_go_to_admin_work!
    end

    @tag accessed_by: "superuser"
    test "superusers also have admin links", %{user: user, html: html} do
      html
      |> logout_allowed!(user)
      |> user_information_shows!(user)
      |> can_go_to_admin_work!
    end
  end

  ## Rendering support
  def render_view_with_layout(conn, view_module, template) do
    assigns = %{layout: {Eecrit.LayoutView, "app.html"},
                conn: conn}
    Phoenix.View.render(view_module, template, assigns) |> to_view_string
  end    
  
  def render_layout(conn),
    do: render_view_with_layout(conn, Eecrit.EmptyView, "index.html")


  ## File-specific assertions
  defchecker login_allowed!(html) do
    html
    |> allows_new!(:session_path, text: "Log in")
    |> disallows_any_delete!(:session_path)
  end

  defchecker logout_allowed!(html, user) do
    html
    |> disallows_new!(:session_path)
    |> allows_delete!([:session_path, user])
  end

  defchecker no_admin_actions!(html) do
    html
    |> disallows_index!(Eecrit.OldAnimal)
    |> disallows_index!(Eecrit.OldProcedure)
  end

  defchecker can_go_to_admin_work!(html) do
    html
    |> allows_index!(Eecrit.OldAnimal, text: "Animals")
    |> allows_index!(Eecrit.OldProcedure, text: "Procedures")
  end    

  defchecker no_user_information_shows!(html) do
    # Pretty indirect way to test this.
    assert length(Floki.find(html, "li")) == 1
  end

  defchecker user_information_shows!(html, user) do
    assert html =~ user.display_name
    assert html =~ User.org_short_name(user)
  end
end
