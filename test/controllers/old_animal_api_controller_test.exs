defmodule Eecrit.OldAnimalApiControllerTest do
  use Eecrit.ConnCase

  # alias Eecrit.OldAnimal
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, old_animal_api_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

end
