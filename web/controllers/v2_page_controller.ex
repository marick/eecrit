defmodule Eecrit.V2PageController do
  use Eecrit.Web, :controller
  # TODO: As far as I can tell, this can't be done in a pipeline in router.ex
  # because `v2_default_layout` uses router helpers.
  import Eecrit.LayoutView, only: [v2_default_layout: 2]
  plug :v2_default_layout

  def index(conn, _params) do
    if conn.assigns.v2_current_user do
      render(conn, "index.html")
    else
      redirect conn, to: v2_page_path(conn, :about)
    end
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end
end
