defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers
  use Eecrit.Helpers.Tags
  import Eecrit.Helpers.Aggregates
  alias Eecrit.Helpers.Logical
  alias Eecrit.Helpers.Bootstrap

  def navbar_data(conn) do
    %{home: Logical.path("Critter4Us", page_path(conn, :index)),
      who: user_description(conn),
      log_in_out: log_in_out(conn),
      reports: [Logical.path("Animal use", report_path(conn, :animal_use))
               ],
      manage: [Logical.resource(conn, "Animals", Eecrit.OldAnimal),
               Logical.resource(conn, "Procedures", Eecrit.OldProcedure),
              ]
    }
  end

  def user_description(conn) do
    current_user = conn.assigns.current_user
    build_if current_user,
      do: "#{current_user.display_name} for #{current_user.current_organization.short_name}"
  end

  def log_in_out(conn) do 
    current_user = conn.assigns.current_user
    if current_user == nil do
      Logical.path("Log in", session_path(conn, :new))
    else
      Logical.path("Log out", session_path(conn, :delete, current_user), method: "delete")
    end
  end

  # Rendering

  def navbar(conn) do
    data = navbar_data(conn)

    nav role: "navigation", class: "navbar navbar-default navbar-fixed-top" do
      div_tag class: "container-fluid" do
        [div_tag class: "navbar-header" do
          [ Logical.to_html(data.home, class: "navbar-brand"),
            Bootstrap.collapse_button("navbar")
          ] end,
         Bootstrap.collapsible_div("navbar") do 
           [ p(data.who, class: "navbar-text"),
             ul_list("nav navbar-nav navbar-right") do
               [ Bootstrap.dropdown("Reports", (Enum.map data.reports, &Logical.to_html/1)),
                 Bootstrap.dropdown("Manage", (Enum.map data.manage, &Logical.to_html/1)),
                 Logical.to_html(data.log_in_out),
               ] end
           ] end
        ] end
    end
  end
end
