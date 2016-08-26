defmodule <%= module %>Test do
  use <%= base %>.ModelCase
  alias <%= module %>

  @valid_attrs <%= inspect params %>
  @empty_attrs %{}

  test "a changeset for the `new` action" do
    changeset = <%= alias %>.new_action_changeset
    refute changeset.valid?
  end

  test "a changeset for the `create` action accepts valid attributes" do 
    changeset = <%= alias %>.create_action_changeset(@valid_attrs)
    assert changeset.valid?
  end
  
  test "a changeset for the `create` action rejects missing attributes" do 
    changeset = <%= alias %>.create_action_changeset(@empty_attrs)
    refute changeset.valid?
  end

  test "an edit changeset contains the original attributes" do
    org = struct(<%= alias %>, @valid_attrs)
    changeset = <%= alias %>.edit_action_changeset(org)
    assert changeset.valid?
    assert changeset.data == org
  end

  test "an update changeset processes update values" do
    org = struct(<%= alias %>, @valid_attrs)
    updates = %{fixme: "please"}  # You must add appropriate selected updates
    changeset = <%= alias %>.update_action_changeset(org, updates)
    assert changeset.valid?
    assert changeset.changes == updates
  end

  test "an update changeset rejects bad values" do
    org = struct(<%= alias %>, @valid_attrs)
    invalids = %{fixme: "please"} # You must add appropriate invalid values
    changeset = <%= alias %>.update_action_changeset(org, invalids)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :fixme)  # Fix this
  end
end
