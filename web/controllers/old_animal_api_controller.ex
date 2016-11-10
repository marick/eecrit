defmodule Eecrit.OldAnimalApiController do
  use Eecrit.Web, :controller
  alias Eecrit.OldAnimal

  def index(conn, _params) do
    data = 
      OldRepo.all(OldAnimal)
      |> Enum.map(&(Map.take(&1, [:id, :name, :kind, :nickname])))

    json conn, %{data: data}
  end
end
