defmodule Eecrit.PageController do
  use Eecrit.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
