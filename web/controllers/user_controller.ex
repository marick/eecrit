defmodule Eecrit.UserController do
  use Eecrit.Web, :controller
  plug :authenticate_user when not action in [:new, :create]
  alias Eecrit.User
  alias Eecrit.Repo

  def index(conn, _params) do
    users = Repo.all(Eecrit.User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(Eecrit.User, String.to_integer(id))
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    render conn, "new.html", changeset: User.empty_creation_changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.checking_creation_changeset(user_params)
    case Repo.insert(changeset) do
      {:ok, user} -> 
        conn
        |> put_flash(:info, "#{user.display_name} created.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
