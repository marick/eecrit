defmodule Eecrit.C4uController do
  use Eecrit.Web, :controller

  def index(conn, _params) do
    conn
    |> put_layout("c4u.html")
    |> render("index.html")
  end
end
