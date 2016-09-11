defmodule Eecrit.PageViewTest do
  use Eecrit.ViewCase, async: true
  alias Eecrit.PageView

  setup context = %{conn: conn} do
    html = render_to_string(PageView, "index.html", conn: conn)
    assign context, html: html, user: conn.assigns.current_user
  end

  @tag accessed_by: "anonymous"
  test "an anonymous user gets just a login link", %{html: html} do
    html
    |> login_allowed!
    |> no_animal_button!
    |> no_procedure_button!
    |> no_reports_available!
    |> no_user_button!
    |> no_organization_button!
    |> no_ability_group_button!
  end

  @tag accessed_by: "user"
  test "a plain user gets nothing!", %{html: html} do
    html
    |> no_login_allowed!
    |> no_animal_button!
    |> no_procedure_button!
    |> no_reports_available!
    |> no_user_button!
    |> no_organization_button!
    |> no_ability_group_button!
  end

  @tag accessed_by: "admin"
  test "an admin has access to admin tasks", %{html: html} do
    html
    |> no_login_allowed!
    |> animal_button!
    |> procedure_button!
    |> reports_available!
    |> no_user_button!
    |> no_organization_button!
    |> no_ability_group_button!
  end

  @tag accessed_by: "superuser"
  test "an admin has access to all tasks", %{html: html} do
    html
    |> no_login_allowed!
    |> animal_button!
    |> procedure_button!
    |> reports_available!
    |> user_button!
    |> organization_button!
    |> ability_group_button!
  end

  # Helpers

  defchecker login_allowed!(html),
    do: allows_new!(html, Eecrit.Session, text: "Please Log In")
  defchecker animal_button!(html),
    do: allows_index!(html, Eecrit.OldAnimal, text: "Work With Animals")
  defchecker procedure_button!(html),
    do: allows_index!(html, Eecrit.OldProcedure, text: "Work With Procedures")
  defchecker user_button!(html),
    do: allows_index!(html, Eecrit.User, text: "Users")
  defchecker organization_button!(html),
    do: allows_index!(html, Eecrit.Organization, text: "Organizations")
  defchecker ability_group_button!(html),
    do: allows_index!(html, Eecrit.AbilityGroup, text: "Ability Groups")
  defchecker reports_available!(html), 
    do: allows_anchor!(html, :animal_use, :report_path, text: "Animal use")

  defchecker no_login_allowed!(html), do: disallows_new!(html, Eecrit.Session);
  defchecker no_animal_button!(html), do: disallows_index!(html, Eecrit.OldAnimal)
  defchecker no_procedure_button!(html), do: disallows_index!(html, Eecrit.OldProcedure)
  defchecker no_user_button!(html), do: disallows_index!(html, Eecrit.User)
  defchecker no_organization_button!(html), do: disallows_index!(html, Eecrit.Organization)
  defchecker no_ability_group_button!(html), do: disallows_index!(html, Eecrit.AbilityGroup)
  defchecker no_reports_available!(html), do: disallows_anchor!(html, :animal_use, :report_path)
end
