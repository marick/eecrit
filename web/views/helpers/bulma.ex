defmodule Eecrit.Helpers.Bulma do
  use Phoenix.HTML
  use Eecrit.Helpers.Tags

  @tab_item_class "nav-item is-tab"

  def tab_item_class(on_page_signified_by_tab: true),
    do: @tab_item_class <> " is-active"
  def tab_item_class(_),
    do: @tab_item_class

  def tab_item(name, path, opts \\ []) do
    link(name, to: path, class: tab_item_class(opts))
  end

  def tab_button(button_text, path, extra_attributes \\ []) do 
    link(button_text,
      [form: [class: @tab_item_class],
       to: path,
       class: "button button-primary nav-item"]
      ++ extra_attributes)
  end
end
