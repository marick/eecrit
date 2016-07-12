defmodule Eecrit.PermissionsTest do
  use Eecrit.ModelCase

  alias Eecrit.Permissions

  @valid_attrs %{can_add_users: true, can_see_admin_page: true, in_all_organizations: true, tag: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Permissions.changeset(%Permissions{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Permissions.changeset(%Permissions{}, @invalid_attrs)
    refute changeset.valid?
  end
end
