defmodule Eecrit.LayoutView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers

  def log_in_out(conn, current_user) do
    if current_user do
      link("Log out", to: session_path(conn, :delete, current_user), method: "delete")
    else
      link "Log in", to: session_path(conn, :new)
    end
  end

  def salutation(conn, current_user) do
    current_user && current_user.display_name
  end
end
