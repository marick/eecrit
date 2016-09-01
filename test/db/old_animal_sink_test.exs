defmodule Eecrit.OldAnimalSinkTest do
  use Eecrit.ModelCase
  alias Eecrit.OldAnimal

  @valid_date "2011-03-29"
  @valid_with_string_date %{kind: "kind", name: "name",
                            procedure_description_kind: hd(OldAnimal.valid_species),
                            date_removed_from_service: @valid_date}

  test "string dates are stored correctly" do
    changeset = OldAnimal.create_action_changeset(@valid_with_string_date)
    assert {:ok, _} = OldRepo.insert(changeset)

    animal = OldRepo.get_by(OldAnimal, name: "name")
    assert animal.date_removed_from_service == Ecto.Date.cast!(@valid_date)
  end
end
