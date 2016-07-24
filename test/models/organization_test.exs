defmodule Eecrit.OrganizationTest do
  use Eecrit.ModelCase

  alias Eecrit.Organization

  @valid_attrs %{full_name: "full name", short_name: "s"}
  @empty_attrs %{}

  test "a changeset for the `new` action" do
    changeset = Organization.new_action_changeset
    refute changeset.valid?
  end

  test "a changeset for the `new` action accepts valid attributes" do 
    changeset = Organization.create_action_changeset(@valid_attrs)
    assert changeset.valid?
  end
  
  test "a changeset for the `new` action rejects missing attributes" do 
    changeset = Organization.create_action_changeset(@empty_attrs)
    refute changeset.valid?
  end


  test "an edit changeset contains the original attributes" do
    org = %Organization{short_name: "a", full_name: "aaaaaa"}
    changeset = Organization.edit_action_changeset(org)
    assert changeset.valid?
    assert changeset.data.full_name == org.full_name
    assert changeset.data.short_name == org.short_name
  end

  test "an update changeset processes update values" do
    org = %Organization{short_name: "a", full_name: "aaaaaa"}
    changeset = Organization.update_action_changeset(org, %{short_name: "b", full_name: "bbbbbb"})
    assert changeset.valid?
    assert changeset.changes.full_name == "bbbbbb"
    assert changeset.changes.short_name == "b"
  end

  test "an update changeset rejects bad values" do
    org = %Organization{short_name: "a", full_name: "aaaaaa"}
    changeset = Organization.update_action_changeset(org, %{short_name: "", full_name: ""})
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :short_name)
    assert Keyword.get(changeset.errors, :full_name)
  end
end
