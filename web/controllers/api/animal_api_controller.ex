defmodule Eecrit.AnimalApiController do
  use Eecrit.Web, :controller
  alias Eecrit.AnimalsProcess
  use Timex

  defp wrapper(stuff), do: %{data: stuff}

  def index(conn, %{"date" => date_string}) do
    animals =
      date_string
      |> Date.from_iso8601!
      |> AnimalsProcess.all
      |> Enum.map(&animal_to_surface_format/1)
    
    json conn, wrapper(animals)
  end

  def create(conn, %{"data" => raw_animal, "original_id" => original_id}) do
    retval =
      raw_animal
      |> animal_from_surface_format
      |> AnimalsProcess.create
    
    case retval do
      {:ok, id} ->
        json conn, wrapper(%{originalId: original_id, serverId: id})
      _ ->
        json conn, %{error: "Creation failed for unknown reasons"}
    end
  end

  def update(conn, %{"data" => raw_animal}) do
    # Process.sleep(10000)
    retval =
      raw_animal
      |> animal_from_surface_format
      |> AnimalsProcess.update
    
    case retval do
      {:ok, id} ->
        json conn, wrapper(%{id: id})
      _ ->
        json conn, %{error: "Update failed for unknown reasons"}
    end
  end

  defp date_from_surface_format(date_string) do
    date_string |> Timex.parse!("{ISO:Extended}") |> Timex.to_date
  end

  defp animal_from_surface_format(params) do
    params
    |> Map.update!("creation_date", &date_from_surface_format/1)
    |> Map.update!("effective_date", &date_from_surface_format/1)
  end

  defp animal_to_surface_format(animal) do
    animal # It happens that nothing needs to be done
  end
end
