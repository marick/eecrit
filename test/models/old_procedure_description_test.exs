defmodule Eecrit.OldProcedureDescriptionTest do
  use Eecrit.ModelCase
  alias Eecrit.OldProcedureDescription

  @valid_attrs %{animal_kind: "bovine", description: "<html/>", procedure_id: 43}
  @invalid_attrs %{}
  @invalid_species "catine"

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

  test "an invalid changeset: missing values" do
    changeset = OldProcedureDescription.create_action_changeset(@invalid_attrs)
    refute changeset.valid?
  end

  test "an invalid changeset: bad animal kind" do
    attrs = Map.put(@valid_attrs, :animal_kind, @invalid_species)
    changeset = OldProcedureDescription.create_action_changeset(attrs)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :animal_kind)
  end
end
