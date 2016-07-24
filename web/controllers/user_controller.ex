defmodule Eecrit.UserController do
  use Eecrit.Web, :controller
  alias Eecrit.User
  alias Eecrit.Repo

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def new(conn, _params) do
    render conn, "new.html", changeset: User.new_action_changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.create_action_changeset(user_params)
    case Repo.insert(changeset) do
      {:ok, user} -> 
        conn
        |> put_flash(:info, "#{user.display_name} created.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render conn, "show.html", user: user
  end

  def edit(conn, %{"id" => _id}) do
    conn
    |> put_flash(:info, "Editing will be done by auth0.")
    |> redirect(to: user_path(conn, :index))
    # user = Repo.get!(User, id)
    # changeset = User.edit_action_changeset(user)
    # render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => _id, "user" => _user_params}) do
    conn
    |> put_flash(:info, "Updates will be done by auth0.")
    |> redirect(to: user_path(conn, :index))
    # user = Repo.get!(User, id)
    # changeset = User.update_action_changeset(user, user_params)

    # case Repo.update(changeset) do
    #   {:ok, user} ->
    #     conn
    #     |> put_flash(:info, "User updated successfully.")
    #     |> redirect(to: user_path(conn, :show, user))
    #   {:error, changeset} ->
    #     render(conn, "edit.html", user: user, changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => _id}) do
    conn
    |> put_flash(:info, "Deletes will be done by auth0.")
    |> redirect(to: user_path(conn, :index))

    # user = Repo.get!(User, id)

    # # Here we use delete! (with a bang) because we expect
    # # it to always work (and if it does not, it will raise).
    # Repo.delete!(user)

    # conn
    # |> put_flash(:info, "Ability group deleted successfully.")
    # |> redirect(to: user_path(conn, :index))
  end
end
