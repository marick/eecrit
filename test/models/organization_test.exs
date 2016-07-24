defmodule Eecrit.OrganizationTest do
  use Eecrit.ModelCase

  alias Eecrit.Organization

  @valid_attrs %{full_name: "full name", short_name: "s"}
  @empty_attrs %{}

  test "a changeset for the `new` action" do
    changeset = Organization.new_action_changeset
    refute changeset.valid?
  end

  test "a changeset for the `create` action accepts valid attributes" do 
    changeset = Organization.create_action_changeset(@valid_attrs)
    assert changeset.valid?
  end
  
  test "a changeset for the `create` action rejects missing attributes" do 
    changeset = Organization.create_action_changeset(@empty_attrs)
    refute changeset.valid?
  end

  test "an edit changeset contains the original attributes" do
    org = struct(Organization, @valid_attrs)
    changeset = Organization.edit_action_changeset(org)
    assert changeset.valid?
    assert changeset.data == org
  end

  test "an update changeset processes update values" do
    org = struct(Organization, @valid_attrs)
    updates = %{short_name: "b"}
    changeset = Organization.update_action_changeset(org, updates)
    assert changeset.valid?
    assert changeset.changes == updates
  end

  test "an update changeset rejects bad values" do
    org = struct(Organization, @valid_attrs)
    invalids = %{short_name: "", full_name: ""}
    changeset = Organization.update_action_changeset(org, invalids)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :short_name)
    assert Keyword.get(changeset.errors, :full_name)
  end
end
