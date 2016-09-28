defmodule Eecrit.IVController do
  use Eecrit.Web, :controller

  def index(conn, _params) do
    conn
    |> put_layout("iv.html")
    |> render("index.html")
  end
end
