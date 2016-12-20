defmodule Eecrit.AnimalApiController do
  use Eecrit.Web, :controller
  alias Eecrit.Animals

  def index(conn, _params) do
    animals = Eecrit.Animals.all
    json conn, %{data: animals}
  end
end
