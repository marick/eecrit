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

  def create(conn, %{"data" => raw_animal,
                     "metadata" => raw_metadata,
                     "original_id" => original_id}) do
    animal = animal_from_surface_format(raw_animal)
    metadata = metadata_from_surface_format(raw_metadata)
    
    retval = AnimalsProcess.create(animal, metadata)
    
    case retval do
      {:ok, id} ->
        json conn, wrapper(%{originalId: original_id, serverId: id})
      _ ->
        json conn, %{error: "Creation failed for unknown reasons"}
    end
  end

  def update(conn, %{"data" => raw_animal, "metadata" => raw_metadata}) do
    animal = animal_from_surface_format(raw_animal)
    metadata = metadata_from_surface_format(raw_metadata)
    
    retval = AnimalsProcess.update(animal, metadata)

    # Process.sleep(10000)

    case retval do
      {:ok, id} ->
        json conn, wrapper(%{id: id})
      _ ->
        json conn, %{error: "Update failed for unknown reasons"}
    end
  end

  def history(conn, %{"id" => idstring}) do
    retval = AnimalsProcess.history(String.to_integer(idstring))
    
    case retval do
      {:ok, history} ->
        json conn, wrapper(history)
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
  end

  defp metadata_from_surface_format(params) do
    params
    |> Map.update!("effective_date", &date_from_surface_format/1)
    |> Map.update!("audit_date", &date_from_surface_format/1)
    |> Map.put_new("audit_author", "demo")  # TEMP
  end

  defp animal_to_surface_format(animal) do
    animal # It happens that nothing needs to be done
  end
end
