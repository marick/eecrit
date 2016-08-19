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
    |> user_button!
    |> organization_button!
    |> ability_group_button!
  end

  # Helpers

  defchecker login_allowed!(html),
    do: allows_new!(html, {"Please Log In", Eecrit.Session})
  defchecker animal_button!(html),
    do: allows_index!(html, {"Work With Animals", Eecrit.OldAnimal})
  defchecker procedure_button!(html),
    do: allows_index!(html, {"Work With Procedures", Eecrit.OldProcedure})
  defchecker user_button!(html),
    do: allows_index!(html, {"Users", Eecrit.User})
  defchecker organization_button!(html),
    do: allows_index!(html, {"Organizations", Eecrit.Organization})
  defchecker ability_group_button!(html),
    do: allows_index!(html, {"Ability Groups", Eecrit.AbilityGroup})

  defchecker no_login_allowed!(html), do: disallows_new!(html, Eecrit.Session);
  defchecker no_animal_button!(html), do: disallows_index!(html, Eecrit.OldAnimal)
  defchecker no_procedure_button!(html), do: disallows_index!(html, Eecrit.OldProcedure)
  defchecker no_user_button!(html), do: disallows_index!(html, Eecrit.User)
  defchecker no_organization_button!(html), do: disallows_index!(html, Eecrit.Organization)
  defchecker no_ability_group_button!(html), do: disallows_index!(html, Eecrit.AbilityGroup)


end
