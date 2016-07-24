defmodule Eecrit.AbilityGroupController do
  use Eecrit.Web, :controller

  alias Eecrit.AbilityGroup

  def index(conn, _params) do
    ability_groups = Repo.all(AbilityGroup)
    render(conn, "index.html", ability_groups: ability_groups)
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: AbilityGroup.new_action_changeset)
  end

  def create(conn, %{"ability_group" => ability_group_params}) do
    changeset = AbilityGroup.create_action_changeset(ability_group_params)

    case Repo.insert(changeset) do
      {:ok, _ability_group} ->
        conn
        |> put_flash(:info, "Ability group created successfully.")
        |> redirect(to: ability_group_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ability_group = Repo.get!(AbilityGroup, id)
    render(conn, "show.html", ability_group: ability_group)
  end

  def edit(conn, %{"id" => id}) do
    ability_group = Repo.get!(AbilityGroup, id)
    changeset = AbilityGroup.edit_action_changeset(ability_group)
    render(conn, "edit.html", ability_group: ability_group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "ability_group" => ability_group_params}) do
    ability_group = Repo.get!(AbilityGroup, id)
    changeset = AbilityGroup.update_action_changeset(ability_group, ability_group_params)

    case Repo.update(changeset) do
      {:ok, ability_group} ->
        conn
        |> put_flash(:info, "Ability group updated successfully.")
        |> redirect(to: ability_group_path(conn, :show, ability_group))
      {:error, changeset} ->
        render(conn, "edit.html", ability_group: ability_group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    ability_group = Repo.get!(AbilityGroup, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(ability_group)

    conn
    |> put_flash(:info, "Ability group deleted successfully.")
    |> redirect(to: ability_group_path(conn, :index))
  end
end
