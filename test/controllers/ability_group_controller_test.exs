defmodule Eecrit.AbilityGroupControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.AbilityGroup
  @valid_attrs %{is_admin: true, is_superuser: true, name: "some content"}
  @invalid_attrs %{name: ""}

  ### Authorization 

  @tag accessed_by: "admin"
  test "anyone less than superuser does not have access", %{conn: conn} do
    conn = get conn, ability_group_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "that includes someone not logged in", %{conn: conn} do
    conn = get conn, ability_group_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  ####
  
  @tag accessed_by: "superuser"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, ability_group_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing ability groups"
  end

  @tag accessed_by: "superuser"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, ability_group_path(conn, :new)
    assert html_response(conn, 200) =~ "New ability group"
  end

  @tag accessed_by: "superuser"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, ability_group_path(conn, :create), ability_group: @valid_attrs
    assert redirected_to(conn) == ability_group_path(conn, :index)
    assert Repo.get_by(AbilityGroup, @valid_attrs)
  end

  @tag accessed_by: "superuser"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, ability_group_path(conn, :create), ability_group: @invalid_attrs
    assert html_response(conn, 200) =~ "New ability group"
  end

  @tag accessed_by: "superuser"
  test "shows chosen resource", %{conn: conn} do
    ability_group = insert_ability_group()
    conn = get conn, ability_group_path(conn, :show, ability_group)
    assert html_response(conn, 200) =~ "Show ability group"
  end

  @tag accessed_by: "superuser"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, ability_group_path(conn, :show, -1)
    end
  end

  @tag accessed_by: "superuser"
  test "renders form for editing chosen resource", %{conn: conn} do
    ability_group = insert_ability_group()
    conn = get conn, ability_group_path(conn, :edit, ability_group)
    assert html_response(conn, 200) =~ "Edit ability group"
  end

  @tag accessed_by: "superuser"
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    ability_group = insert_ability_group()
    conn = put conn, ability_group_path(conn, :update, ability_group), ability_group: @valid_attrs
    assert redirected_to(conn) == ability_group_path(conn, :show, ability_group)
    assert Repo.get_by(AbilityGroup, @valid_attrs)
  end

  @tag accessed_by: "superuser"
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ability_group = insert_ability_group()
    conn = put conn, ability_group_path(conn, :update, ability_group), ability_group: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit ability group"
  end

  @tag :skip
  test "deletes chosen resource", %{conn: conn} do
    ability_group = insert_ability_group()
    conn = delete conn, ability_group_path(conn, :delete, ability_group)
    assert redirected_to(conn) == ability_group_path(conn, :index)
    refute Repo.get(AbilityGroup, ability_group.id)
  end
end
