defmodule Eecrit.OldAnimalTest do
  use Eecrit.ModelCase

  alias Eecrit.OldAnimal

  @valid_attrs %{date_removed_from_service: %{day: 17, month: 4, year: 2010}, kind: "some content", name: "some content", nickname: "some content", procedure_description_kind: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OldAnimal.changeset(%OldAnimal{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OldAnimal.changeset(%OldAnimal{}, @invalid_attrs)
    refute changeset.valid?
  end
end
