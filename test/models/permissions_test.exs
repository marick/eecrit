defmodule Eecrit.PermissionsTest do
  use Eecrit.ModelCase

  alias Eecrit.Permissions

  @valid_attrs %{is_superuser: true, is_admin: true, tag: "some content"}
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
