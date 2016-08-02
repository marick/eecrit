defmodule Eecrit.OldAnimalTest do
  use Eecrit.ModelCase

  alias Eecrit.OldAnimal

  @valid_date "2012-02-29"
  @invalid_date "2011-01-32"

  @valid_attrs %{kind: "kind", name: "name", procedure_description_kind: "species"}
  @optional_attrs %{nickname: "nickname", date_removed_from_service: @valid_date}
  @invalid_attrs %{}

  test "a starting changeset" do
    changeset = OldAnimal.new_action_changeset()
    refute changeset.valid?
  end

  # Creation

  test "changeset with only required attributes" do
    changeset = OldAnimal.create_action_changeset(@valid_attrs)
    assert changeset.valid?
    assert changeset.changes == @valid_attrs
  end

  test "changeset with all attributes" do
    attrs = Map.merge(@valid_attrs, @optional_attrs)
    changeset = OldAnimal.create_action_changeset(attrs)
    assert changeset.valid?
    assert changeset.changes.date_removed_from_service == Ecto.Date.cast!(@valid_date)
  end

  test "an invalid changeset" do
    attrs = Map.put(@valid_attrs, :date_removed_from_service, @invalid_date)
    changeset = OldAnimal.create_action_changeset(attrs)
    refute changeset.valid?
    assert Keyword.get(changeset.errors, :date_removed_from_service)
  end
end
