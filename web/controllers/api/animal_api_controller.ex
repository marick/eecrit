defmodule Eecrit.AnimalApiController do
  use Eecrit.Web, :controller
  alias Eecrit.Animals
  alias Eecrit.V2Animal, as: Animal
  use Timex

  defp wrapper(stuff), do: %{data: stuff}

  def index(conn, %{"date" => date_string}) do
    animals =
      date_string
      |> Date.from_iso8601!
      |> Animals.all
      |> Enum.map(&animal_to_surface_format/1)
    
    json conn, wrapper(animals)
  end

  def update(conn, %{"data" => animal}) do
    # Process.sleep(10000)
    case Animals.update(animal) do
      {:ok, result} ->
        json conn, wrapper(result)
      _ ->
        json conn, %{error: "Update failed for unknown reasons"}
    end
  end

  def create(conn, %{"data" => raw_animal, "original_id" => original_id}) do
    retval =
      raw_animal
      |> animal_from_surface_format
      |> Animals.create(original_id)
    
    case retval do
      {:ok, animals} ->
        json conn, wrapper(animals)
      _ ->
        json conn, %{error: "Creation failed for unknown reasons"}
    end
  end

  defp date_from_surface_format(date_string) do
    date_string |> Timex.parse!("{ISO:Extended}") |> Timex.to_date
  end

  defp animal_from_surface_format(params) do
    Apex.ap params
    Map.update!(params, "creation_date", &date_from_surface_format/1)
  end

  defp animal_to_surface_format(animal) do
    animal # It happens that nothing needs to be done
  end
end
