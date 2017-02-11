Code.require_file("v2_animal_data.exs", __DIR__)

defmodule Eecrit.V2AnimalTest do
  use ExUnit.Case, async: true
  alias Eecrit.VersionedAnimal
  alias Eecrit.V2AnimalData, as: Data
  use Timex

  describe "empty" do 
    test "creation returns id" do
      {animals, id} =
        VersionedAnimal.create(%{},
          Data.animal_params(%{"id" => "not 1"}),
          Data.metadata_params)
      assert id  == 1
      assert Map.size(animals) == 1
    end
  end

  describe "a fresh animal" do
    setup do 
      {animals, 1} =
        VersionedAnimal.create(
          %{},
          Data.animal_params(%{"creation_date" => Data.middle_date}),
          Data.metadata_params(%{"effective_date" => Data.middle_date}))
                               
      [animals: animals]
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
      assert animal.effective_date == Data.middle_date
    end

    test "`all` doesn't return the animal if it hasn't been created yet", %{animals: animals} do
      [] = VersionedAnimal.all(animals, Data.early_date)
    end

    test "boundaries", %{animals: animals} do
      [] = VersionedAnimal.all(animals, Timex.shift(Data.middle_date, days: -1))
      [_animal] = VersionedAnimal.all(animals, Timex.shift(Data.middle_date, days: 0))
      [_animal] = VersionedAnimal.all(animals, Timex.shift(Data.middle_date, days: 1))
    end
  end

  describe "updating an animal" do
    setup do
      first = Data.animal_params(%{"creation_date" => Data.early_middle_date,
                                   "name" => "early middle"})
      metafirst = Data.metadata_params(%{"effective_date" => Data.early_middle_date})
      second = Data.animal_params(%{"name" => "middle latest",
                                    "id" => 1
                                   })
      metasecond = Data.metadata_params(%{"effective_date" => Data.middle_latest_date})
      
      {with_first, 1} = VersionedAnimal.create(%{}, first, metafirst)
      with_second = VersionedAnimal.update(with_first, second, metasecond)
      [animals: with_second]
    end
    
    test "all still doesn't return an animal that hasn't been created yet",
      %{animals: animals} do
      [] = VersionedAnimal.all(animals, Data.early_date)
    end
    
    test "it returns the original if date is before the update", 
    %{animals: animals} do
      [animal] = VersionedAnimal.all(animals, Data.early_middle_date)
      
      assert animal.id == 1
      assert animal.name == "early middle"
    end
    
    test "note that the version is always the latest, for optimistic locking",
      %{animals: animals} do
      
      [animal] = VersionedAnimal.all(animals, Data.early_middle_date)
      assert animal.version == 2  
    end
    
    test "or it can return a newer one", 
    %{animals: animals} do
      [animal] = VersionedAnimal.all(animals, Data.middle_latest_date)
      
      assert animal.id == 1
      assert animal.version == 2
      assert animal.name == "middle latest"  # name change is seen
    end
    
    test "updates needn't be applied in order", %{animals: animals} do
      between = Data.animal_params(%{"name" => "middle",
                                     "id" => 1})
      metabetween = Data.metadata_params(%{"effective_date" => Data.middle_date})
      with_between = VersionedAnimal.update(animals, between, metabetween)

      [animal] = VersionedAnimal.all(with_between, Data.middle_latest_date)
      assert animal.id == 1
      assert animal.version == 3
      assert animal.name == "middle latest"

      [animal] = VersionedAnimal.all(with_between, Data.middle_date)
      assert animal.id == 1
      assert animal.version == 3
      assert animal.name == "middle"
      
      [animal] = VersionedAnimal.all(with_between, Data.early_middle_date)
      assert animal.id == 1
      assert animal.version == 3
      assert animal.name == "early middle"
    end

    test "you can replace an existing snapshot", %{animals: animals} do
      changed = Data.animal_params(%{"name" => "NEW MIDDLE CHANGED",
                                     "id" => 1})
      metachanged = Data.metadata_params(%{"effective_date" => Data.middle_latest_date})
      with_changed = VersionedAnimal.update(animals, changed, metachanged)

      [animal] = VersionedAnimal.all(with_changed, Data.middle_latest_date)
      assert animal.id == 1
      assert animal.version == 3
      assert animal.name == "NEW MIDDLE CHANGED"

      [animal] = VersionedAnimal.all(with_changed, Data.early_middle_date)
      assert animal.id == 1
      assert animal.version == 3
      assert animal.name == "early middle"
    end

    test "you can even replace the original", %{animals: animals} do
      changed = Data.animal_params(%{"name" => "NEW START",
                                     "id" => 1})
      metachanged = Data.metadata_params(%{"effective_date" => Data.early_middle_date})
      with_changed = VersionedAnimal.update(animals, changed, metachanged)

      [animal] = VersionedAnimal.all(with_changed, Data.early_middle_date)
      assert animal.id == 1
      assert animal.version == 3
      assert animal.name == "NEW START"

      # Note that later edits are NOT overridden
      [animal] = VersionedAnimal.all(with_changed, Data.middle_latest_date)
      assert animal.id == 1
      assert animal.version == 3
      assert animal.name == "middle latest"
    end
  end
end
