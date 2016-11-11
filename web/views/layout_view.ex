defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers
  use Eecrit.Helpers.Tags
  import Eecrit.Helpers.Aggregates
  alias Eecrit.Helpers.Logical
  alias Eecrit.Helpers.Bootstrap

  def navbar_data(conn) do
    %{home: Logical.path("Critter4Us", page_path(conn, :index)),
      user: conn.assigns.current_user,
      dropdowns: dropdowns(conn)
      reports: [Logical.path("Animal use", report_path(conn, :animal_use))
               ],
      manage: [Logical.resource(conn, "Animals", Eecrit.OldAnimal),
               Logical.resource(conn, "Procedures", Eecrit.OldProcedure),
              ]
    }
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
           [ m_p(user_description(data.user), class: "navbar-text"),
             ul_list("nav navbar-nav navbar-right") do
               [ Bootstrap.dropdown("Reports", (Enum.map data.reports, &Logical.to_html/1)),
                 Bootstrap.dropdown("Manage", (Enum.map data.manage, &Logical.to_html/1)),

                 log_in_out(conn, data.user)
               ] end
           ] end
        ] end
    end
  end

  def user_description(current_user) do
    build_if current_user,
      do: "#{current_user.display_name} for #{current_user.current_organization.short_name}"
  end

  # Todo: these don't have the right indentation when the window is small

  def log_in_out(conn, current_user = nil) do 
    link("Log in", to: session_path(conn, :new))
    |> p(class: "navbar-text")
  end

  def log_in_out(conn, current_user) do
    link("Log out", to: session_path(conn, :delete, current_user),
      method: "delete", class: "navbar-text")
  end
end
