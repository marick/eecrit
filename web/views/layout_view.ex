defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers

  
  def li_log_in_out(conn, nil) do
    link("Log in", to: session_path(conn, :new)) |> li()
  end
  def li_log_in_out(conn, user) do
    link("Log out", to: session_path(conn, :delete, user), method: "delete") |> li()
  end

  def li_salutation(_conn, nil), do: nil
  def li_salutation(_conn, user), do: user.display_name |> li()

  def li_organization(_conn, nil), do: nil
  def li_organization(_conn, user), do: user.current_organization.short_name |> li()

  def li_animals(_conn, nil), do: nil
  def li_animals(conn, user) do
    if user.ability_group.is_admin do
      link("Animals", to: old_animal_path(conn, :index)) |> li()
    end
  end

  defp li(content), do: content_tag(:li, content)
end
