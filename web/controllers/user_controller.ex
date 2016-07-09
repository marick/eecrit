defmodule Eecrit.UserController do
  use Eecrit.Web, :controller
  plug :authenticate when not action in [:new, :create]
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
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.password_setting_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} -> 
        conn
        |> Eecrit.Auth.login(user)
        |> put_flash(:info, "#{user.display_name} created.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to see that page.")
      |> redirect(to: page_path(conn, :index))
      |> halt
    end
  end
end