defmodule Eecrit.SessionPlugsTest do
  use Eecrit.PlugCase
  alias Eecrit.SessionPlugs
  alias Eecrit.AbilityGroupChooser
  alias Eecrit.AbilityGroup
  alias Eecrit.Organization
  alias Eecrit.User

  describe "an `:add_current_user` function" do
    def subject(conn, user_id) do
      SessionPlugs.add_current_user(conn, :_args, user_id).assigns.current_user
    end
    
    setup context do
      organization = insert_organization(short_name: "org")
      user = insert_user(login_name: "user", current_organization: organization)
      ability_group = insert_ability_group(name: "group")

      Repo.insert!(%AbilityGroupChooser{user_id: user.id,
                                        organization_id: organization.id,
                                        ability_group_id: ability_group.id})

      Dict.put(context, :user_id, user.id)
    end

    
    test "no user id means nil current user", %{conn: conn} do
      assert subject(conn, nil) == nil
    end

    test "a user is assigned, associated to organization and ability group",
      %{conn: conn, user_id: user_id} do
      
      actual = subject(conn, user_id)
      assert actual.login_name == "user"
      assert actual.current_organization.short_name == "org"
      assert actual.ability_group.name == "group"
    end

    # Bad inputs
    
    test "a stale userid prevents login",
      %{conn: conn, user_id: user_id} do

      Repo.delete(Repo.get(User, user_id))
      assert subject(conn, user_id) == nil
    end
    
    test "a missing ability group prevents login",
      %{conn: conn, user_id: user_id} do

      Repo.delete(Repo.get_by(AbilityGroup, name: "group"))
      assert subject(conn, user_id) == nil
    end
    
    test "a missing organization prevents login",
      %{conn: conn, user_id: user_id} do
      Repo.delete(Repo.get_by(Organization, short_name: "org"))
      assert subject(conn, user_id) == nil
    end
  end


  test "page access plugs (`require_X`)", %{conn: conn} do
    run_plug = fn(user, plug) ->
      conn_with_user =
        conn
        |> Arrange.add_plug_session()
        |> ConnTest.fetch_flash()
        |> Conn.assign(:current_user, user)
      apply(SessionPlugs, plug, [conn_with_user, :_args])
    end

    flash_from = fn(user, plug) ->
      result = run_plug.(user, plug)
      unless result.halted, do: raise "plug did not halt the conn"
      result |> get_flash |> Dict.get("error")
    end

    no_user = nil
    plain_user = make_user(ability_group: make_ability_group("user"))
    admin = make_user(ability_group: make_ability_group("admin"))
    superuser = make_user(ability_group: make_ability_group("superuser"))

    assert flash_from.(no_user, :require_login) =~ "Please log in"
    refute run_plug.(plain_user, :require_login).halted
    refute run_plug.(admin, :require_login).halted
    refute run_plug.(superuser, :require_login).halted

    # Note that we assume the pipeline has already checked for
    # a logged-in user.
    # TODO: This looks like a job for Null Object
    assert flash_from.(plain_user, :require_admin) =~ "You aren't permitted"
    refute run_plug.(admin, :require_admin).halted
    refute run_plug.(superuser, :require_admin).halted

    assert flash_from.(plain_user, :require_superuser) =~ "You aren't permitted"
    assert flash_from.(admin, :require_superuser) =~ "You aren't permitted"
    refute run_plug.(superuser, :require_superuser).halted
  end
end
