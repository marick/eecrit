defmodule Eecrit.V2AnimalTest do
  use ExUnit.Case, async: true
  alias Eecrit.VersionedAnimal
  alias Eecrit.VersionedAnimal.Snapshot, as: Snapshot
  alias Eecrit.V2AnimalData, as: Data
  use Timex

  describe "empty" do 
    test "creation returns id" do
      {animals, id} =
        VersionedAnimal.create(%{}, Data.animal_params(%{"id" => "not 1"}))
      assert id  == 1
      assert Map.size(animals) == 1
    end
  end
  
  describe "a fresh animal" do
    setup do 
      {animals, _} =
        VersionedAnimal.create(%{},
          Data.animal_params(%{"creation_date" => Data.middle_date}))
      {:ok, animals: animals}
    end
    
    test "what the retrieved animal looks like", %{animals: animals} do
      [animal] = VersionedAnimal.all(animals, Data.middle_date)

      assert animal.id == 1
      assert animal.version == 1
      assert animal.name == Data.animal_params["name"]
      assert animal.species == Data.animal_params["species"]
      assert animal.tags == Data.animal_params["tags"]
      assert animal.int_properties == Data.animal_params["int_properties"]
      assert animal.bool_properties == Data.animal_params["bool_properties"]
      assert animal.string_properties == Data.animal_params["string_properties"]
      assert animal.creation_date == Data.middle_date
    end

    test "`all` doesn't return the animal if it hasn't been created yet", %{animals: animals} do
      [] = VersionedAnimal.all(animals, Data.early_date)
    end

    test "boundaries", %{animals: animals} do
      [] = VersionedAnimal.all(animals, Timex.shift(Data.middle_date, days: -1))
      [animal] = VersionedAnimal.all(animals, Timex.shift(Data.middle_date, days: 0))
      [animal] = VersionedAnimal.all(animals, Timex.shift(Data.middle_date, days: 1))
    end
  end

  describe "updating an animal" do
  end

end
