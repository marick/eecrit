defmodule Eecrit.OrganizationController do
  use Eecrit.Web, :controller
  alias Eecrit.Organization

  def index(conn, _params) do
    organizations = Repo.all(Organization)
    render(conn, "index.html", organizations: organizations)
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Organization.new_action_changeset)
  end

  def create(conn, %{"organization" => params}) do
    changeset = Organization.create_action_changeset(params)

    case Repo.insert(changeset) do
      {:ok, _organization} ->
        conn
        |> put_flash(:info, "Organization created successfully.")
        |> redirect(to: organization_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    organization = Repo.get!(Organization, id)
    render(conn, "show.html", organization: organization)
  end

  def edit(conn, %{"id" => id}) do
    organization = Repo.get!(Organization, id)
    changeset = Organization.edit_action_changeset(organization)
    render(conn, "edit.html", organization: organization, changeset: changeset)
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    organization = Repo.get!(Organization, id)
    changeset = Organization.update_action_changeset(organization, organization_params)

    case Repo.update(changeset) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, "Organization updated successfully.")
        |> redirect(to: organization_path(conn, :show, organization))
      {:error, changeset} ->
        render(conn, "edit.html", organization: organization, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    organization = Repo.get!(Organization, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(organization)

    conn
    |> put_flash(:info, "Organization deleted successfully.")
    |> redirect(to: organization_path(conn, :index))
  end
end
