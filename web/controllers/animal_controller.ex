defmodule Eecrit.AnimalController do
  use Eecrit.Web, :controller

  alias Eecrit.Animal
  alias Eecrit.ElmView

  def index(conn, _params) do
    ElmView.start(conn, "animals-index")
  end

  def new(conn, _params) do
    ElmView.start(conn, "animals-new")
  end

end