defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers

  def li_log_in_out(conn, current_user) do
    content = if current_user do
      link("Log out", to: session_path(conn, :delete, current_user), method: "delete")
    else
      link "Log in", to: session_path(conn, :new)
    end

    content_tag(:li, content)
  end

  def li_salutation(_conn, current_user) do
    if current_user, do: content_tag(:li, current_user.display_name)
  end
end
