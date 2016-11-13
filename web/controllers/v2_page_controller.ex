defmodule Eecrit.V2PageController do
  use Eecrit.Web, :controller

  def index(conn, _params) do
    conn
    |> put_layout("v2_layout.html")
    |> render("index.html")
  end
end
