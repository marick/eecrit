defmodule Eecrit.UserController do
  use Eecrit.Web, :controller

  def index(conn, _params) do
    users = Repo.all(Eecrit.User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(Eecrit.User, String.to_integer(id))
    render conn, "show.html", user: user
  end
end

  
