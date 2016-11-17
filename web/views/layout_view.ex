defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers

  # use Eecrit.Helpers.Tags
  alias Eecrit.Helpers.Tags
  import Eecrit.Helpers.Aggregates
  alias Eecrit.Helpers.Logical
  alias Eecrit.Helpers.Bootstrap
  import Eecrit.ControlFlow
  alias Eecrit.Helpers.Bulma
  alias Plug.Conn

  # TODO: Have so far been unable to use a V2LayoutView - it's not available
  # when template is compiled.

  @home "Home"
  @about "About"

  defp handler_to_tab_name(conn) do
    case {Controller.controller_module(conn), Controller.action_name(conn)} do
      {Eecrit.V2PageController, :index} -> @home
      {Eecrit.V2PageController, :about} -> @about
      _ -> :not_relevant_to_navigation_bar
    end
  end

  def tab_item_options(conn, name) do
    [on_page_signified_by_tab: handler_to_tab_name(conn) == name]
  end

  defp tab_item(conn, name, path),
    do: Bulma.tab_item(name, path, tab_item_options(conn, name))

  defp maybe_home(so_far, conn) do
    list_augment_if conn.assigns.v2_current_user, so_far do
      tab_item(conn, @home, v2_page_path(conn, :index))
    end
  end

  defp maybe_about(so_far, conn) do
    always_present = tab_item(conn, @about, v2_page_path(conn, :about))
    [always_present | so_far]
  end

  defp maybe_logout(so_far, conn) do
    current_user = conn.assigns.v2_current_user
    list_augment_if current_user, so_far do
      Bulma.tab_button("Log out", v2_session_path(conn, :delete, current_user),
        method: :delete)
    end
  end

  def navbar_items(conn) do
    []
    |> maybe_home(conn)
    |> maybe_about(conn)
    |> maybe_logout(conn)
    |> Enum.reverse
  end

  defp v2_user_description(conn) do
    if conn.assigns.v2_current_user do
      "Trial User at Demo U"
    else
      ""
    end
  end
  
  def v2_default_layout(conn, _opts) do
    layout_data = 
      %{left_picture_path: v2_page_path(conn, :index),
        user: v2_user_description(conn),
        links: navbar_items(conn)
       }

    conn
    |> Controller.put_layout("v2_layout_default.html")
    |> Conn.assign(:layout_data, layout_data)
  end


  defp one_flash(conn, color, key) do
    flash = Controller.get_flash(conn, key)
    list_if flash do
      Tags.nav class: "notification #{color}" do
        flash
      end
    end
  end

  def v2_flash(conn) do
    [one_flash(conn, "is-success", :success),
     one_flash(conn, "is-info", :info), 
     one_flash(conn, "is-danger", :error),
    ]
  end


  #######
  ######## The below is all for *V1*
  #######
  
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
    list_if current_user, do: current_user.display_name
  end

  def organization(conn) do
    current_user = conn.assigns.current_user
    list_if current_user, do: current_user.current_organization.short_name
  end

end
