defmodule Eecrit.AnimalApiController do
  use Eecrit.Web, :controller
  alias Eecrit.Animals

  def index(conn, _params) do
    animals = Eecrit.Animals.all
    json conn, %{data: animals}
  end

  def update(conn, params) do
    IO.puts (inspect params)
    json conn, %{data: %{id: Map.get(params, "id"), version: 888}}
  end
end
