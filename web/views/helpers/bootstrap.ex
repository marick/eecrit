defmodule Eecrit.Helpers.Bootstrap do
  use Eecrit.Helpers.Tags
  import Eecrit.Helpers.Aggregates

  def collapsible_div(id, do: components) do
    div_tag components,
      class: "collapse navbar-collapse", id: "navbar"
  end

  def collapse_button(corresponding_div_id) do
    button_tag(type: "button", class: "navbar-toggle",
               data_toggle: "collapse", data_target: "#"<>corresponding_div_id) do
      [ span("Toggle header", class: "sr-only"),
        span("", class: "icon-bar"),
        span("", class: "icon-bar"),
        span("", class: "icon-bar"),
      ]
    end
  end

  def dropdown(name, list_links) do
    list_button = [ name, span("", class: "caret")]
    
    whole =
      a(class: "dropdown-toggle", data_toggle: "dropdown", href: "#") do
      [list_button] ++ ul_list("dropdown-menu", do: list_links)
    end
    li(whole, class: "dropdown")
  end
end
