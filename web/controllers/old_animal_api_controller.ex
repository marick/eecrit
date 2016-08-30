defmodule Eecrit.OldAnimalApiController do
  use Eecrit.Web, :controller

  alias Eecrit.OldAnimal

  def index(conn, _params) do
    old_animals = OldRepo.all(OldAnimal)
    render(conn, "index.json", old_animals: old_animals)
  end
end
