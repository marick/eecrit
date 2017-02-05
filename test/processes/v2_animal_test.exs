Code.require_file("v2_animal_data.exs", __DIR__)

defmodule Eecrit.V2AnimalTest do
  use ExUnit.Case, async: true
  alias Eecrit.VersionedAnimal
  alias Eecrit.VersionedAnimal.Snapshot
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
      {animals, 1} =
        VersionedAnimal.create(
          %{},
          Data.animal_params(%{"creation_date" => Data.middle_date}))
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
    setup do
      first = Data.animal_params(%{"creation_date" => Data.early_middle_date})
      second = Data.animal_params(%{"creation_date" => Data.middle_latest_date, 
                                    "tags" => ["early", "middle", "tags"],
                                    "id" => 1
                                   })
      
      {with_first, 1} = VersionedAnimal.create(%{}, first)
      with_second = VersionedAnimal.update(with_first, second)
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
      assert animal.creation_date == Data.early_middle_date
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
      assert animal.creation_date == Data.middle_latest_date
    end
  end


  alias Eecrit.VersionedAnimal.Private, as: P
  describe "private functions" do
    test "nothing to select" do
      assert P.snapshot_no_later_than([], Data.early_date) == nil
    end

    test "all snapshots in the list are later than the date" do
      no = Snapshot.new(creation_date: Data.latest_date)
      assert P.snapshot_no_later_than([no], Data.middle_latest_date) == nil
    end

    test "finds a snapshot that's just on the date" do
      yes = Snapshot.new(creation_date: Data.middle_latest_date)
      assert P.snapshot_no_later_than([yes], Data.middle_latest_date) == yes
    end

    test "finds a snapshot that's earlier than the date" do
      yes = Snapshot.new(creation_date: Data.middle_latest_date)
      assert P.snapshot_no_later_than([yes], Data.latest_date) == yes
    end

    test "find the MOST RECENT snapshot that's earlier than the date" do
      earliest = Snapshot.new(creation_date: Data.early_date)
      middlest = Snapshot.new(creation_date: Data.middle_date)
      latest = Snapshot.new(creation_date: Data.latest_date)

      list = [latest, middlest, earliest]
      assert P.snapshot_no_later_than(list, Data.early_date) == earliest
      assert P.snapshot_no_later_than(list, Data.early_middle_date) == earliest
      assert P.snapshot_no_later_than(list, Data.middle_date) == middlest
      assert P.snapshot_no_later_than(list, Data.middle_latest_date) == middlest
      assert P.snapshot_no_later_than(list, Data.latest_date) == latest
    end
    
  end
end
