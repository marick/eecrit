defmodule Eecrit.OldAnimalController do
  use Eecrit.Web, :controller

  alias Eecrit.OldAnimal

  def index(conn, _params) do
    animals = OldRepo.all(OldAnimal)
    render(conn, "index.html", animals: animals)
  end

  def new(conn, _params) do
    changeset = OldAnimal.changeset(%OldAnimal{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"old_animal" => old_animal_params}) do
    changeset = OldAnimal.changeset(%OldAnimal{}, old_animal_params)

    case OldRepo.insert(changeset) do
      {:ok, _old_animal} ->
        conn
        |> put_flash(:info, "Old animal created successfully.")
        |> redirect(to: old_animal_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    old_animal = OldRepo.get!(OldAnimal, id)
    render(conn, "show.html", old_animal: old_animal)
  end

  def edit(conn, %{"id" => id}) do
    old_animal = OldRepo.get!(OldAnimal, id)
    changeset = OldAnimal.changeset(old_animal)
    render(conn, "edit.html", old_animal: old_animal, changeset: changeset)
  end

  def update(conn, %{"id" => id, "old_animal" => old_animal_params}) do
    old_animal = OldRepo.get!(OldAnimal, id)
    changeset = OldAnimal.changeset(old_animal, old_animal_params)

    case OldRepo.update(changeset) do
      {:ok, old_animal} ->
        conn
        |> put_flash(:info, "Old animal updated successfully.")
        |> redirect(to: old_animal_path(conn, :show, old_animal))
      {:error, changeset} ->
        render(conn, "edit.html", old_animal: old_animal, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    old_animal = OldRepo.get!(OldAnimal, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    OldRepo.delete!(old_animal)

    conn
    |> put_flash(:info, "Old animal deleted successfully.")
    |> redirect(to: old_animal_path(conn, :index))
  end
end
