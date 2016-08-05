defmodule Eecrit.OldAnimalControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.OldAnimal
  @valid_attrs %{kind: "some content", name: "ANIMAL NAME",
                 procedure_description_kind: hd(OldAnimal.valid_species)}
  @invalid_attrs %{name: ""}

  ### Authorization 

  @tag accessed_by: "user"
  test "anyone less than superuser does not have access", %{conn: conn} do
    conn = get conn, old_animal_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "that includes someone not logged in", %{conn: conn} do
    conn = get conn, old_animal_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  ## Index
  
  @tag accessed_by: "admin"
  test "lists only currently-in-service entries by default", %{conn: conn} do
    insert_old_animal(name: "retained", date_removed_from_service: nil)
    removed_at = Ecto.Date.cast!("2012-03-05")
    insert_old_animal(name: "removed", date_removed_from_service: removed_at)
    conn = get conn, old_animal_path(conn, :index)
    assert html_response(conn, 200) =~ "All animals currently in service"
    assert Enum.find(conn.assigns.animals, &(&1.name == "retained"))
    refute Enum.find(conn.assigns.animals, &(&1.name == "removed"))
  end

  @tag accessed_by: "admin"
  test "animals with future removal dates are still shown", %{conn: conn} do
    insert_old_animal(name: "retained", date_removed_from_service: nil)
    insert_old_animal(name: "removed",
                      date_removed_from_service: Ecto.Date.cast!("2092-03-05"))
    conn = get conn, old_animal_path(conn, :index)
    assert html_response(conn, 200) =~ "All animals currently in service"
    assert Enum.find(conn.assigns.animals, &(&1.name == "retained"))
    assert Enum.find(conn.assigns.animals, &(&1.name == "removed"))
  end

  @tag accessed_by: "admin"
  test "Can be made to list out-of-service entries", %{conn: conn} do
    insert_old_animal(name: "retained", date_removed_from_service: nil)
    
    insert_old_animal(name: "removed",
                      date_removed_from_service: Ecto.Date.cast!("2012-03-05"))
    conn = get conn, old_animal_path(conn, :index, include_out_of_service: true)
    assert html_response(conn, 200) =~ "All animals"
    refute html_response(conn, 200) =~ "All animals currently in service"
    assert Enum.find(conn.assigns.animals, &(&1.name == "retained"))
    assert Enum.find(conn.assigns.animals, &(&1.name == "removed"))
  end
  
  @tag accessed_by: "admin"
  test "entries are listed in alphabetical order", %{conn: conn} do
    unordered = ~w{s d l1 0 b a L2 m o}
    Enum.map(unordered, &(insert_old_animal(name: &1)))
    conn = get conn, old_animal_path(conn, :index)
    assert Enum.map(conn.assigns.animals, &(&1.name)) == ~w{0 a b d l1 L2 m o s}
  end

  ## NEW
  
  @tag accessed_by: "admin"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, old_animal_path(conn, :new)
    assert html_response(conn, 200) =~ "New animal"
    assert conn.assigns.valid_species == OldAnimal.valid_species()
  end

  ## CREATE

  @tag accessed_by: "admin"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, old_animal_path(conn, :create), old_animal: @valid_attrs
    assert redirected_to(conn) == old_animal_path(conn, :index)
    assert OldRepo.get_by(OldAnimal, @valid_attrs)
    assert html_response(conn, 302)
    assert flash_matches(conn, "info", ~r{ANIMAL NAME was created})
  end

  @tag accessed_by: "admin"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, old_animal_path(conn, :create), old_animal: @invalid_attrs
    assert html_response(conn, 200) =~ "New animal"
    assert html_response(conn, 200) =~ "be blank"
  end

  ## SHOW
  
  @tag accessed_by: "admin"
  test "shows chosen resource", %{conn: conn} do
    old_animal = insert_old_animal(name: "Betsy")
    conn = get conn, old_animal_path(conn, :show, old_animal)
    assert html_response(conn, 200) =~ ~s{The animal named "Betsy"}
  end

  @tag accessed_by: "admin"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, old_animal_path(conn, :show, -1)
    end
  end

  ## Render edit form
  
  @tag accessed_by: "admin"
  test "renders form for editing chosen resource", %{conn: conn} do
    old_animal = insert_old_animal(name: "Betsy")
    conn = get conn, old_animal_path(conn, :edit, old_animal)
    assert html_response(conn, 200) =~ ~s{Edit "Betsy"}
  end

  @tag accessed_by: "admin"
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    old_animal = insert_old_animal()
    conn = put conn, old_animal_path(conn, :update, old_animal), old_animal: @valid_attrs
    assert redirected_to(conn) == old_animal_path(conn, :show, old_animal)
    assert OldRepo.get_by(OldAnimal, @valid_attrs)
  end

  @tag accessed_by: "admin"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    old_animal = insert_old_animal(name: "Betsy")
    conn = put conn, old_animal_path(conn, :update, old_animal), old_animal: @invalid_attrs
    assert html_response(conn, 200) =~ ~s{Edit "Betsy"}
  end

  # :delete
  
  @tag accessed_by: "admin"
  test "deletes chosen resource", %{conn: conn} do
    animal = insert_old_animal()
    conn = delete conn, old_animal_path(conn, :delete, animal)
    assert redirected_to(conn) == old_animal_path(conn, :index)
    refute OldRepo.get(OldAnimal, animal.id)
  end

end
