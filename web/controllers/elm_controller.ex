defmodule Eecrit.ElmController do
  use Eecrit.Web, :controller
  import Eecrit.LayoutView, only: [v2_default_layout: 2]
  plug :v2_default_layout

  def index(conn, _params) do
    render conn, "index.html"
  end

  def choose_page(conn, params) do
    render(conn, "page.html", div: inspect(params))
  end
end
