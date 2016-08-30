defmodule Eecrit.OldAnimalApiControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldAnimalApi
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, old_animal_api_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    old_animal_api = Repo.insert! %OldAnimalApi{}
    conn = get conn, old_animal_api_path(conn, :show, old_animal_api)
    assert json_response(conn, 200)["data"] == %{"id" => old_animal_api.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_animal_api_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, old_animal_api_path(conn, :create), old_animal_api: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(OldAnimalApi, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, old_animal_api_path(conn, :create), old_animal_api: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    old_animal_api = Repo.insert! %OldAnimalApi{}
    conn = put conn, old_animal_api_path(conn, :update, old_animal_api), old_animal_api: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(OldAnimalApi, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    old_animal_api = Repo.insert! %OldAnimalApi{}
    conn = put conn, old_animal_api_path(conn, :update, old_animal_api), old_animal_api: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    old_animal_api = Repo.insert! %OldAnimalApi{}
    conn = delete conn, old_animal_api_path(conn, :delete, old_animal_api)
    assert response(conn, 204)
    refute Repo.get(OldAnimalApi, old_animal_api.id)
  end
end
