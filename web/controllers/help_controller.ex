defmodule Eecrit.HelpController do
  use Eecrit.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", video: %{id: "irrelevant"}
  end
end
