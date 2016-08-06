defmodule Eecrit.OldProcedureDescriptionTest do
  use Eecrit.ModelCase

  alias Eecrit.OldProcedureDescription

  @valid_attrs %{animal_kind: "some content", description: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OldProcedureDescription.changeset(%OldProcedureDescription{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OldProcedureDescription.changeset(%OldProcedureDescription{}, @invalid_attrs)
    refute changeset.valid?
  end
end
