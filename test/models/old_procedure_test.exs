defmodule Eecrit.OldProcedureTest do
  use Eecrit.ModelCase

  alias Eecrit.OldProcedure

  @valid_attrs %{days_delay: 42, name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OldProcedure.changeset(%OldProcedure{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OldProcedure.changeset(%OldProcedure{}, @invalid_attrs)
    refute changeset.valid?
  end
end
