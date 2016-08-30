defmodule Eecrit.OldAnimalApiController do
  use Eecrit.Web, :controller

  alias Eecrit.OldAnimal

  def index(conn, _params) do
    old_animals = OldRepo.all(OldAnimal)
    IO.puts "==================\n\n\OLD ANIMALS"
    render(conn, "index.json", old_animals: old_animals)
  end

  def create(conn, %{"old_animal_api" => old_animal_api_params}) do
    # changeset = OldAnimal.changeset(%OldAnimal{}, old_animal_api_params)

    # case OldRepo.insert(changeset) do
    #   {:ok, old_animal_api} ->
    #     conn
    #     |> put_status(:created)
    #     |> put_resp_header("location", old_animal_api_path(conn, :show, old_animal_api))
    #     |> render("show.json", old_animal_api: old_animal_api)
    #   {:error, changeset} ->
    #     conn
    #     |> put_status(:unprocessable_entity)
    #     |> render(Eecrit.ChangesetView, "error.json", changeset: changeset)
    # end
  end

  def show(conn, %{"id" => id}) do
    # old_animal_api = OldRepo.get!(OldAnimal, id)
    # render(conn, "show.json", old_animal_api: old_animal_api)
  end

  def update(conn, %{"id" => id, "old_animal_api" => old_animal_api_params}) do
    # old_animal_api = OldRepo.get!(OldAnimal, id)
    # changeset = OldAnimal.changeset(old_animal_api, old_animal_api_params)

    # case OldRepo.update(changeset) do
    #   {:ok, old_animal_api} ->
    #     render(conn, "show.json", old_animal_api: old_animal_api)
    #   {:error, changeset} ->
    #     conn
    #     |> put_status(:unprocessable_entity)
    #     |> render(Eecrit.ChangesetView, "error.json", changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => id}) do
    # old_animal_api = OldRepo.get!(OldAnimal, id)

    # # Here we use delete! (with a bang) because we expect
    # # it to always work (and if it does not, it will raise).
    # OldRepo.delete!(old_animal_api)

    # send_resp(conn, :no_content, "")
  end
end
