defmodule Eecrit.OldAnimalControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldAnimal
  @valid_attrs %{date_removed_from_service: %{day: 17, month: 4, year: 2010}, kind: "some content", name: "some content", nickname: "some content", procedure_description_kind: "some content"}
  @invalid_attrs %{}

  ## Index
  
  @tag accessed_by: "admin"
  test "lists all UNDELETED entries by default", %{conn: conn} do
    retained = insert_old_animal(name: "retained", date_removed_from_service: nil)
    {:ok, removed_at} = Ecto.Date.cast("2012-03-05")
    deleted = insert_old_animal(name: "removed", date_removed_from_service: removed_at)
    conn = get conn, old_animal_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing animals"
    Apex.ap conn.assigns
    assert Enum.find(conn.assigns.animals, &(&1.name == "retained"))
    refute Enum.find(conn.assigns.animals, &(&1.name == "removed"))
  end

  




  
  @tag accessed_by: "admin", skip: true
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, old_animal_path(conn, :new)
    assert html_response(conn, 200) =~ "New old animal"
  end

  @tag accessed_by: "admin", skip: true
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, old_animal_path(conn, :create), old_animal: @valid_attrs
    assert redirected_to(conn) == old_animal_path(conn, :index)
    assert OldRepo.get_by(OldAnimal, @valid_attrs)
  end

  @tag accessed_by: "admin", skip: true
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, old_animal_path(conn, :create), old_animal: @invalid_attrs
    assert html_response(conn, 200) =~ "New old animal"
  end

  @tag accessed_by: "admin", skip: true
  test "shows chosen resource", %{conn: conn} do
    old_animal = OldRepo.insert! %OldAnimal{}
    conn = get conn, old_animal_path(conn, :show, old_animal)
    assert html_response(conn, 200) =~ "Show old animal"
  end

  @tag accessed_by: "admin", skip: true
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_animal_path(conn, :show, -1)
    end
  end

  @tag accessed_by: "admin", skip: true
  test "renders form for editing chosen resource", %{conn: conn} do
    old_animal = OldRepo.insert! %OldAnimal{}
    conn = get conn, old_animal_path(conn, :edit, old_animal)
    assert html_response(conn, 200) =~ "Edit old animal"
  end

  @tag accessed_by: "admin", skip: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    old_animal = OldRepo.insert! %OldAnimal{}
    conn = put conn, old_animal_path(conn, :update, old_animal), old_animal: @valid_attrs
    assert redirected_to(conn) == old_animal_path(conn, :show, old_animal)
    assert OldRepo.get_by(OldAnimal, @valid_attrs)
  end

  @tag accessed_by: "admin", skip: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    old_animal = OldRepo.insert! %OldAnimal{}
    conn = put conn, old_animal_path(conn, :update, old_animal), old_animal: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit old animal"
  end
end
