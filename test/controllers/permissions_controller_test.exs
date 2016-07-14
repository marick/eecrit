defmodule Eecrit.PermissionsControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.Permissions
  @valid_attrs %{can_add_users: true, can_see_admin_page: true, in_all_organizations: true, tag: "some content"}
  @invalid_attrs %{}

  setup do
    user = insert_user(display_name: "Logged In")
    conn = assign(build_conn, :current_user, user)
    {:ok, conn: conn, user: user}
  end
  
  test "all actions must be authenticated" do
    Enum.each([
      get(build_conn, permissions_path(build_conn, :new)),
      get(build_conn, permissions_path(build_conn, :index)),
      get(build_conn, permissions_path(build_conn, :show, "123")),
      get(build_conn, permissions_path(build_conn, :edit, "123")),
      put(build_conn, permissions_path(build_conn, :update, "123", %{})),
      post(build_conn, permissions_path(build_conn, :create, %{})),
      delete(build_conn, permissions_path(build_conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  test "lists all entries on :index", %{conn: conn} do
    insert_permissions(tag: "This is a tag")
    conn = get conn, permissions_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing permissions"
    assert String.contains?(conn.resp_body, "This is a tag")
  end

  @tag :skip
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, permissions_path(conn, :new)
    assert html_response(conn, 200) =~ "New permissions"
  end

  @tag :skip
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, permissions_path(conn, :create), permissions: @valid_attrs
    assert redirected_to(conn) == permissions_path(conn, :index)
    assert Repo.get_by(Permissions, @valid_attrs)
  end

  @tag :skip
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, permissions_path(conn, :create), permissions: @invalid_attrs
    assert html_response(conn, 200) =~ "New permissions"
  end

  @tag :skip
  test "shows chosen resource", %{conn: conn} do
    permissions = Repo.insert! %Permissions{}
    conn = get conn, permissions_path(conn, :show, permissions)
    assert html_response(conn, 200) =~ "Show permissions"
  end

  @tag :skip
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, permissions_path(conn, :show, -1)
    end
  end

  @tag :skip
  test "renders form for editing chosen resource", %{conn: conn} do
    permissions = Repo.insert! %Permissions{}
    conn = get conn, permissions_path(conn, :edit, permissions)
    assert html_response(conn, 200) =~ "Edit permissions"
  end

  @tag :skip
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    permissions = Repo.insert! %Permissions{}
    conn = put conn, permissions_path(conn, :update, permissions), permissions: @valid_attrs
    assert redirected_to(conn) == permissions_path(conn, :show, permissions)
    assert Repo.get_by(Permissions, @valid_attrs)
  end

  @tag :skip
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    permissions = Repo.insert! %Permissions{}
    conn = put conn, permissions_path(conn, :update, permissions), permissions: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit permissions"
  end

  @tag :skip
  test "deletes chosen resource", %{conn: conn} do
    permissions = Repo.insert! %Permissions{}
    conn = delete conn, permissions_path(conn, :delete, permissions)
    assert redirected_to(conn) == permissions_path(conn, :index)
    refute Repo.get(Permissions, permissions.id)
  end
end
