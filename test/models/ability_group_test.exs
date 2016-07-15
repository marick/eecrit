defmodule Eecrit.AbilityGroupTest do
  use Eecrit.ModelCase

  alias Eecrit.AbilityGroup

  @valid_attrs %{is_admin: true, is_superuser: true, name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = AbilityGroup.changeset(%AbilityGroup{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = AbilityGroup.changeset(%AbilityGroup{}, @invalid_attrs)
    refute changeset.valid?
  end
end
