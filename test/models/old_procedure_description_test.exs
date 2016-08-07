defmodule Eecrit.OldProcedureDescriptionTest do
  use Eecrit.ModelCase
  alias Eecrit.OldProcedureDescription

  @valid_attrs %{animal_kind: "bovine", description: "<html/>"}
  @invalid_attrs %{}

  test "a starting changeset" do
    changeset = OldProcedureDescription.new_action_changeset()
    refute changeset.valid?
  end

  # Creation

  test "changeset with all required attributes" do
    changeset = OldProcedureDescription.create_action_changeset(@valid_attrs)
    assert changeset.valid?
    assert changeset.changes == @valid_attrs
  end

  test "an invalid changeset" do
    changeset = OldProcedureDescription.create_action_changeset(@invalid_attrs)
    refute changeset.valid?
  end
end
