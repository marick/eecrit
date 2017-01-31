defmodule Eecrit.AnimalApiController do
  use Eecrit.Web, :controller
  alias Eecrit.Animals
  alias Eecrit.V2Animal, as: Animal

  defp wrapper(stuff), do: %{data: stuff}

  def index(conn, %{"date" => date_string}) do
    date = Date.from_iso8601!(date_string)
    animals = Animals.all(date) |> Enum.map(&Animal.to_interchange_format/1)
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

  def create(conn, %{"data" => animal, "original_id" => original_id}) do
    case Animals.create(original_id, animal) do
      {:ok, result} ->
        json conn, wrapper(result)
      _ ->
        json conn, %{error: "Creation failed for unknown reasons"}
    end
  end
end
