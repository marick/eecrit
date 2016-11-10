defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers
  import Eecrit.TagHelpers.Macros
  alias Eecrit.TagHelpers, as: T
  alias Eecrit.AggregateViewWidgets

  def link_data(name, path, extras \\ []),
    do: %{name: name, path: path, extras: extras}
  
  def navbar_data(conn) do
    %{home: link_data("Critter4Us", page_path(conn, :index)),
      who: user_description(conn),
      log_in_out: log_in_out_new(conn),
      reports: [
                link_data("Animal use", report_path(conn, :animal_use))
               ],
      manage: [
               T.m_resource_link(conn, "Animals", Eecrit.OldAnimal),
               T.m_resource_link(conn, "Procedures", Eecrit.OldProcedure),
              ]
    }
  end

  def expand_link_data(link_data, extras \\ []),
    do: link(link_data.name, [to: link_data.path] ++ extras)

  def collapse_button(id) do
    T.button(type: "button", class: "navbar-toggle",
             data_toggle: "collapse", data_target: "#"<>id) do
      [ T.span("Toggle header", class: "sr-only"),
        T.span("", class: "icon-bar"),
        T.span("", class: "icon-bar"),
        T.span("", class: "icon-bar"),
      ]
    end
  end

  def collapsible_div(id, do: components) do
    T.div components,
      class: "collapse navbar-collapse", id: "navbar"
  end

  def ul_list(class, do: items) do
    T.ul class: class do
      Enum.map items, &T.li/1
    end
  end

  def dropdown(name, list_links) do
    list_button = [ name, T.span("", class: "caret")]

    whole =
      T.a(class: "dropdown-toggle", data_toggle: "dropdown", href: "#") do
      [list_button] ++ ul_list("dropdown-menu", do: list_links)
    end
    T.li(whole, class: "dropdown")
  end
  
  def navbar(conn) do
    data = navbar_data(conn)

    T.nav role: "navigation", class: "navbar navbar-default" do
      T.div class: "container-fluid" do
        [T.div class: "navbar-header" do
          [ expand_link_data(data.home, class: "navbar-brand"),
            collapse_button("navbar")
          ]
         end,
         collapsible_div("navbar") do 
           [ T.p(data.who, class: "navbar-text"),
             ul_list("nav navbar-nav navbar-right") do
               [dropdown("Reports", (Enum.map data.reports, &expand_link_data/1)),
                dropdown("Manage", data.manage),
                expand_link_data(data.log_in_out),
               ]
             end
           ]
         end
        ]
      end
    end
  end





  ### 
  

  def navigation(conn) do
    iolists = [
      link("Home", to: page_path(conn, :index)),
      AggregateViewWidgets.reports_launcher(conn),
      T.m_resource_link(conn, "Animals", Eecrit.OldAnimal),
      T.m_resource_link(conn, "Procedures", Eecrit.OldProcedure),
      salutation(conn),
      organization(conn),
      log_in_out(conn),
    ]

    Enum.map(iolists, &T.li/1)
  end

  def log_in_out_new(conn) do 
    current_user = conn.assigns.current_user
    if current_user == nil do
      link_data("Log in", session_path(conn, :new))
    else
      link_data("Log out", session_path(conn, :delete, current_user), method: "delete")
    end
  end

  def log_in_out(conn) do
    current_user = conn.assigns.current_user
    if current_user == nil do
      link("Log in", to: session_path(conn, :new))
    else
      link("Log out", to: session_path(conn, :delete, current_user), method: "delete")
    end
  end
    
  def user_description(conn) do
    current_user = conn.assigns.current_user
    build_if current_user,
      do: "#{current_user.display_name} for #{current_user.current_organization.short_name}"
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
