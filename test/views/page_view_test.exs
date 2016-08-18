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

  defp login_allowed!(html),
    do: allows_new!(html, {"Please Log In", Eecrit.Session})
  defp animal_button!(html),
    do: allows_index!(html, {"Work With Animals", Eecrit.OldAnimal})
  defp procedure_button!(html),
    do: allows_index!(html, {"Work With Procedures", Eecrit.OldProcedure})
  defp user_button!(html),
    do: allows_index!(html, {"Users", Eecrit.User})
  defp organization_button!(html),
    do: allows_index!(html, {"Organizations", Eecrit.Organization})
  defp ability_group_button!(html),
    do: allows_index!(html, {"Ability Groups", Eecrit.AbilityGroup})

  defp no_login_allowed!(html), do: disallows_new!(html, Eecrit.Session);
  defp no_animal_button!(html), do: disallows_index!(html, Eecrit.OldAnimal)
  defp no_procedure_button!(html), do: disallows_index!(html, Eecrit.OldProcedure)
  defp no_user_button!(html), do: disallows_index!(html, Eecrit.User)
  defp no_organization_button!(html), do: disallows_index!(html, Eecrit.Organization)
  defp no_ability_group_button!(html), do: disallows_index!(html, Eecrit.AbilityGroup)


end
