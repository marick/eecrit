defmodule Eecrit.OrganizationTest do
  use Eecrit.ModelCase

  alias Eecrit.Organization

  @valid_attrs %{full_name: "some content"}
  @invalid_attrs %{}

  @tag :skip
  test "changeset with valid attributes" do
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag :skip
  test "changeset with invalid attributes" do
    changeset = Organization.changeset(%Organization{}, @invalid_attrs)
    refute changeset.valid?
  end
end
