defmodule Eecrit.Helpers.Bootstrap do
  use Eecrit.Helpers.Tags
  import Eecrit.Helpers.Aggregates
  alias Eecrit.Helpers.Logical

  def collapsible_div(id, do: components) do
    div_tag components,
      class: "collapse navbar-collapse", id: id
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

  def dropdown(nil), do: []
  def dropdown(logical) do
    list_button = [ logical.name, span("", class: "caret")]
    list_entries = Enum.map logical.elements, &Logical.to_html/1
    dropdown_list = [list_button | ul_list("dropdown-menu", do: list_entries)]

    showable = a(class: "dropdown-toggle", data_toggle: "dropdown", href: "#") do
      dropdown_list
    end
    li(showable, class: "dropdown")
  end
end
