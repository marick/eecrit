defmodule Eecrit.AbilityGroupTest do
  use Eecrit.ModelCase

  alias Eecrit.AbilityGroup

  @valid_attrs %{is_admin: true, is_superuser: true, name: "some content"}
  @empty_attrs %{}
  
  test "a changeset for the `new` action" do
    changeset = AbilityGroup.new_action_changeset
    refute changeset.valid?
  end

  test "a changeset for the `new` action accepts valid attributes" do 
    changeset = AbilityGroup.create_action_changeset(@valid_attrs)
    assert changeset.valid?
  end
  
  test "a changeset for the `new` action rejects missing attributes" do 
    changeset = AbilityGroup.create_action_changeset(@empty_attrs)
    refute changeset.valid?
  end

  test "an edit changeset contains the original attributes" do
    org = struct(AbilityGroup, @valid_attrs)
    changeset = AbilityGroup.edit_action_changeset(org)
    assert changeset.valid?
    assert changeset.data == org
  end

  test "an update changeset processes update values" do
    org = struct(AbilityGroup, @valid_attrs)
    updates = %{is_admin: false, is_superuser: false, name: "new name"}
    changeset = AbilityGroup.update_action_changeset(org, updates)
    assert changeset.valid?
    assert changeset.changes == updates
  end

  test "an update changeset rejects bad values" do
    org = struct(AbilityGroup, @valid_attrs)
    invalids = %{name: ""}
    changeset = AbilityGroup.update_action_changeset(org, invalids)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :name)
  end
end
