defmodule Eecrit.PermissionsController do
  use Eecrit.Web, :controller

  alias Eecrit.Permissions

  def index(conn, _params) do
    permissions = Repo.all(Permissions)
    render(conn, "index.html", permissions: permissions)
  end

  def new(conn, _params) do
    changeset = Permissions.changeset(%Permissions{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"permissions" => permissions_params}) do
    changeset = Permissions.changeset(%Permissions{}, permissions_params)

    case Repo.insert(changeset) do
      {:ok, _permissions} ->
        conn
        |> put_flash(:info, "Permissions created successfully.")
        |> redirect(to: permissions_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    permissions = Repo.get!(Permissions, id)
    render(conn, "show.html", permissions: permissions)
  end

  def edit(conn, %{"id" => id}) do
    permissions = Repo.get!(Permissions, id)
    changeset = Permissions.changeset(permissions)
    render(conn, "edit.html", permissions: permissions, changeset: changeset)
  end

  def update(conn, %{"id" => id, "permissions" => permissions_params}) do
    permissions = Repo.get!(Permissions, id)
    changeset = Permissions.changeset(permissions, permissions_params)

    case Repo.update(changeset) do
      {:ok, permissions} ->
        conn
        |> put_flash(:info, "Permissions updated successfully.")
        |> redirect(to: permissions_path(conn, :show, permissions))
      {:error, changeset} ->
        render(conn, "edit.html", permissions: permissions, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    permissions = Repo.get!(Permissions, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(permissions)

    conn
    |> put_flash(:info, "Permissions deleted successfully.")
    |> redirect(to: permissions_path(conn, :index))
  end
end
