defmodule Eecrit.UserControllerTest do
  use Eecrit.ConnCase

  alias Eecrit.User
  @valid_attrs %{display_name: "Dawn Marick",
                 login_name: "dster@critter4us.com",
                 password: "password"}
  @invalid_attrs %{name: ""}


  ### Authorization 

  @tag accessed_by: "admin"
  test "anyone less than superuser does not have access", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "that includes someone not logged in", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert redirected_to(conn) == page_path(conn, :index)
  end

  ####
  
  @tag accessed_by: "superuser"
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  @tag accessed_by: "superuser"
  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  @tag accessed_by: "superuser"
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, login_name: @valid_attrs.login_name)
  end

  @tag accessed_by: "superuser"
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  @tag accessed_by: "superuser"
  test "shows chosen resource", %{conn: conn} do
    user = insert_user()
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  @tag accessed_by: "superuser"
  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  # Not bothering with all the rest of this, as users are created
  # programmatically for now, will probably auth0 in the future.

  # @tag accessed_by: "superuser"
  # test "renders form for editing chosen resource", %{conn: conn} do
  #   user = insert_user()
  #   conn = get conn, user_path(conn, :edit, user)
  #   assert html_response(conn, 200) =~ "Edit user"
  # end

  # @tag accessed_by: "superuser"
  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   user = insert_user()
  #   conn = put conn, user_path(conn, :update, user), user: @valid_attrs
  #   assert redirected_to(conn) == user_path(conn, :show, user)
  #   assert Repo.get_by(User, @valid_attrs)
  # end

  # @tag accessed_by: "superuser"
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   user = insert_user()
  #   conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit user"
  # end

  # @tag :skip
  # test "deletes chosen resource", %{conn: conn} do
  #   user = insert_user()
  #   conn = delete conn, user_path(conn, :delete, user)
  #   assert redirected_to(conn) == user_path(conn, :index)
  #   refute Repo.get(User, user.id)
  # end
end
