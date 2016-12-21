defmodule Eecrit.AnimalApiController do
  use Eecrit.Web, :controller
  alias Eecrit.Animals

  defp wrapper(stuff), do: %{data: stuff}

  def index(conn, _params) do
    animals = Animals.all
    json conn, wrapper(animals)
  end

  def update(conn, %{"data" => animal}) do
    IO.puts (inspect animal)
    case Animals.update(animal) do
      {:ok, result} ->
        json conn, wrapper(result)
      _ ->
        json conn, %{error: "Update failed for unknown reasons"}
    end
  end
end
