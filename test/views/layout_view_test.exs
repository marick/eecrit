defmodule Eecrit.LayoutViewTest do
  use Eecrit.ViewCase
  alias Eecrit.LayoutView


  having "a complete page (layout plus empty content)" do 
    should "not blow up", %{conn: conn} do
      assert render_layout(conn) =~ "Critter4Us"
    end
  end
    
  having("a navigation bar") do
    # TODO: Interesting that the `context` argument for `setup` can't be like
    #        setup(%{conn: conn} = context) do
    # It works, but you get a "warning: variable conn is unused"
    setup context do
      html = render_view_helper(context.conn, &LayoutView.navigation/1)
      assign context, html: html
    end

    @tag accessed_by: "anonymous"
    should "provide a login link for an anonymous user", %{conn: conn, html: html} do
      {conn, html}
      |> should_allow_login
      |> should_show_no_user_information
      |> should_allow_no_admin_actions
    end

    @tag accessed_by: "user"
    should "let a plain user do nothing but log out", %{conn: conn, html: html} do
      {conn, html}
      |> should_allow_logout
      |> should_show_user_information
      |> should_allow_no_admin_actions
    end
    
    @tag accessed_by: "admin"
    should "give admins quick links to do their job", %{conn: conn, html: html} do
      {conn, html}
      |> should_allow_logout
      |> should_show_user_information
      |> should_allow_admin_work
    end

    @tag accessed_by: "superuser"
    should "give a superuser has same powers as admin", %{conn: conn, html: html} do
      {conn, html}
      |> should_allow_logout
      |> should_show_user_information
      |> should_allow_admin_work
    end
  end

  defp current_user(conn), do: conn.assigns.current_user
  defp current_user_display_name(conn), do: current_user(conn).display_name
  defp current_user_org_short_name(conn),
    do: current_user(conn).current_organization.short_name

  ## File-specific assertions
  defp should_allow_login({conn, html}) do
    login_path = session_path(conn, :new)
    
    html
    |> should_contain_link({"Log in", login_path})
    |> should_not_contain_link_text("Log out")
    {conn, html}
  end

  defp should_allow_logout({conn, html}) do
    login_path = session_path(conn, :new)

    html
    |> should_not_contain_link({"Log in", login_path})
    |> should_contain_link_text("Log out")
    {conn, html}
  end

  defp should_allow_no_admin_actions({conn, html}) do
    animal_path = old_animal_path(conn, :index)
    procedure_path = old_procedure_path(conn, :index)

    html
    |> should_not_contain_link({"Animals", animal_path})
    |> should_not_contain_link({"Procedures", procedure_path})
    {conn, html}
  end

  defp should_allow_admin_work({conn, html}) do
    animal_path = old_animal_path(conn, :index)
    procedure_path = old_procedure_path(conn, :index)

    html
    |> should_contain_link({"Animals", animal_path})
    |> should_contain_link({"Procedures", procedure_path})
    {conn, html}
  end    

  defp should_show_no_user_information({conn, html}) do
    # Pretty indirect way to test this.
    assert length(Floki.find(html, "li")) == 1
    {conn, html}
  end

  defp should_show_user_information({conn, html}) do
    assert html =~ current_user_display_name(conn)
    assert html =~ current_user_org_short_name(conn)
    {conn, html}
  end
end
