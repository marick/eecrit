defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers
  use Eecrit.TagHelpers
  alias Eecrit.AggregateViewWidgets

  def navigation(conn) do
    iolists = [
      link("Home", to: page_path(conn, :index)),
      AggregateViewWidgets.reports_launcher(conn),
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

end
