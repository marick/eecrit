defmodule <%= module %>ControllerTest do
  use <%= base %>.ConnCase

  alias <%= module %>
  @valid_attrs <%= inspect params %>
  @invalid_attrs %{}
  @intended_for "admin"   # MAY CHANGE THIS

  ### Authorization

  describe "who is NOT allowed access" do 
    @tag accessed_by: "user"
    test "anyone less than admin does not have access", %{conn: conn} do
      conn = get conn, <%= singular %>_path(conn, :index)
      assert redirected_to(conn) == page_path(conn, :index)
    end

    @tag accessed_by: "anonymous"
    test "that includes someone not logged in", %{conn: conn} do
      conn = get conn, <%= singular %>_path(conn, :index)
      assert redirected_to(conn) == page_path(conn, :index)
    end
  end

  ### Actions

  describe "INDEX action" do 
    @tag accessed_by: @intended_for
    test "lists all entries on index", %{conn: conn} do
      conn = get conn, <%= singular %>_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing <%= template_plural %>"
    end
  end

  
  describe "NEW action" do 
    @tag accessed_by: @intended_for
    test "renders form for new resources", %{conn: conn} do
      conn = get conn, <%= singular %>_path(conn, :new)
      assert html_response(conn, 200) =~ "New <%= template_singular %>"
    end
  end

  
  describe "CREATE action" do 
    @tag accessed_by: @intended_for
    test "creates resource and redirects when data is valid", %{conn: conn} do
      conn = post conn, <%= singular %>_path(conn, :create), <%= singular %>: @valid_attrs
      assert redirected_to(conn) == <%= singular %>_path(conn, :index)
      assert Repo.get_by(<%= alias %>, @valid_attrs)
    end
    
    @tag accessed_by: @intended_for
    test "does not create resource and renders errors when data is invalid", %{conn: conn} do
      conn = post conn, <%= singular %>_path(conn, :create), <%= singular %>: @invalid_attrs
      assert html_response(conn, 200) =~ "New <%= template_singular %>"
    end
  end

  
  describe "SHOW action" do 
    @tag accessed_by: @intended_for
    test "shows chosen resource", %{conn: conn} do
      <%= singular %> = Repo.insert! %<%= alias %>{}
      conn = get conn, <%= singular %>_path(conn, :show, <%= singular %>)
      assert html_response(conn, 200) =~ "Show <%= template_singular %>"
    end

    @tag accessed_by: @intended_for
    test "renders page not found when id is nonexistent", %{conn: conn} do
      assert_error_sent 404, fn ->
        get conn, <%= singular %>_path(conn, :show, <%= inspect sample_id %>)
      end
    end
  end


  describe "EDIT action" do 
    @tag accessed_by: @intended_for
    test "renders form for editing chosen resource", %{conn: conn} do
      <%= singular %> = Repo.insert! %<%= alias %>{}
      conn = get conn, <%= singular %>_path(conn, :edit, <%= singular %>)
      assert html_response(conn, 200) =~ "Edit <%= template_singular %>"
    end
  end


  describe "UPDATE action" do 
    @tag accessed_by: @intended_for
    test "updates chosen resource and redirects when data is valid", %{conn: conn} do
      <%= singular %> = Repo.insert! %<%= alias %>{}
      conn = put conn, <%= singular %>_path(conn, :update, <%= singular %>), <%= singular %>: @valid_attrs
      assert redirected_to(conn) == <%= singular %>_path(conn, :show, <%= singular %>)
      assert Repo.get_by(<%= alias %>, @valid_attrs)
    end
    
    @tag accessed_by: @intended_for
    test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
      <%= singular %> = Repo.insert! %<%= alias %>{}
      conn = put conn, <%= singular %>_path(conn, :update, <%= singular %>), <%= singular %>: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit <%= template_singular %>"
    end
  end

  
  describe "DELETE action" do 
    @tag accessed_by: @intended_for
    test "deletes chosen resource", %{conn: conn} do
      <%= singular %> = Repo.insert! %<%= alias %>{}
      conn = delete conn, <%= singular %>_path(conn, :delete, <%= singular %>)
      assert redirected_to(conn) == <%= singular %>_path(conn, :index)
      refute Repo.get(<%= alias %>, <%= singular %>.id)
    end
  end
end
