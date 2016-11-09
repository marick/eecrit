defmodule Eecrit.OldAnimalController do
  use Eecrit.Web, :controller

  alias Eecrit.OldAnimalSource
  alias Eecrit.OldAnimal

  def index(conn, params) do
    include_out_of_service? = Map.has_key?(params, "include_out_of_service")
    animals =
      OldAnimalSource.all_ordered(include_out_of_service: include_out_of_service?)
    render(conn, "index.html", animals: animals, params: params)
  end

  def elmindex(conn, params) do
    animals =
      OldAnimalSource.all_ordered(include_out_of_service: false)
    render(conn, "elmindex.html", animals: animals, params: params)
  end

  def new(conn, _params) do
    render_new(conn, OldAnimal.new_action_changeset)
  end

  def create(conn, %{"old_animal" => old_animal_params}) do
    changeset = OldAnimal.create_action_changeset(old_animal_params)

    case OldRepo.insert(changeset) do
      {:ok, animal} ->
        conn
        |> put_flash(:info, "#{animal.name} was created.")
        |> redirect(to: old_animal_path(conn, :index))
      {:error, changeset} ->
        render_new(conn, changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    old_animal = OldRepo.get!(OldAnimal, id)
    render(conn, "show.html", old_animal: old_animal)
  end

  def edit(conn, %{"id" => id}) do
    old_animal = OldRepo.get!(OldAnimal, id)
    changeset = OldAnimal.edit_action_changeset(old_animal)
    render_edit(conn, old_animal, changeset)
  end

  def update(conn, %{"id" => id, "old_animal" => old_animal_params}) do
    old_animal = OldRepo.get!(OldAnimal, id)
    changeset = OldAnimal.update_action_changeset(old_animal, old_animal_params)
    case OldRepo.update(changeset) do
      {:ok, old_animal} ->
        conn
        |> put_flash(:info, "#{old_animal.name} has been changed.")
        |> redirect(to: old_animal_path(conn, :show, old_animal))
      {:error, changeset} ->
        render_edit(conn, old_animal, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    old_animal = OldRepo.get!(OldAnimal, id)
    OldRepo.delete!(old_animal)

    conn
    |> put_flash(:info, "Animal deleted successfully.")
    |> redirect(to: old_animal_path(conn, :index))
  end


  defp render_new(conn, changeset) do
    render(conn, "new.html", changeset: changeset,
                             valid_species: OldAnimal.valid_species)
  end

  defp render_edit(conn, old_animal, changeset) do
    render(conn, "edit.html", old_animal: old_animal,
                              valid_species: OldAnimal.valid_species,
                              changeset: changeset)
  end
end
