defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers
  use Eecrit.TagHelpers
  alias Eecrit.TagHelpers, as: T   # TODO: this is a kludge to avoid conflicts

  def navigation(conn) do
    iolists = [
      dropdown_launcher(conn, "Reports", report_links(conn)),
      m_resource_link(conn, "Animals", Eecrit.OldAnimal),
      m_resource_link(conn, "Procedures", Eecrit.OldProcedure),
      salutation(conn),
      organization(conn),
      log_in_out(conn),
    ]

    Enum.map(iolists, &li/1)
  end

  def log_in_out(conn) do
    current_user = conn.assigns.current_user
    if current_user == nil do
      link("Log in", to: session_path(conn, :new))
    else
      link("Log out", to: session_path(conn, :delete, current_user), method: "delete")
    end
  end
    
  def salutation(conn) do
    current_user = conn.assigns.current_user
    build_if current_user, do: current_user.display_name
  end

  def organization(conn) do
    current_user = conn.assigns.current_user
    build_if current_user, do: current_user.current_organization.short_name
  end

  def report_links(conn) do
    [
      link("Animal use", to: report_path(conn, :animal_use)),
    ]
  end

  def dropdown_button(title, button_size \\ "btn_xs") do
    button_attrs = [type: "button",
                    class: "btn btn-default #{button_size} dropdown-toggle",
                    data_toggle: "dropdown",
                    aria_haspopup: "true",
                    aria_expanded: "false"]

    [title, " ", symbol_span("caret")]
    |> T.button(button_attrs)
  end

  def dropdown_launcher(conn, title, links, button_size \\ "btn-xs") do
    # For whatever reason, a dropdown button list requires a menu and a button.
    build_if can?(conn.assigns.current_user, :work_with, :reports) do 
      button_part = dropdown_button(title, button_size)
      menu_part = links |> Enum.map(&li/1) |> T.ul(class: "dropdown-menu")
      T.div([button_part, menu_part], class: "btn-group")
    end
  end
end
