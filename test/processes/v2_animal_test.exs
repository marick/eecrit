defmodule Eecrit.V2AnimalTest do
  use ExUnit.Case, async: true
  alias Eecrit.VersionedAnimal
  alias Eecrit.VersionedAnimal.Snapshot, as: Snapshot
  use Timex

  @early_date ~D[2015-03-01]
  @middle_date ~D[2016-03-01]
  @later_date ~D[2017-03-01]
  @latest_date ~D[2018-03-01]
  
  @new_animal %{"id" => "ignored",
                "version" => "ignored",
                "name" => "new animal", 
                "species" => "equine", 
                "tags" => [ "stallion", "aggressive" ],
                "int_properties" => %{"val" => [1, "x"]},
                "bool_properties" => %{"Available" => [true, ""]},
                "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
                "creation_date" => @middle_date
  }

  # API calls used in setup
  def api_create(animals, new), do: VersionedAnimal.create(animals, new)

  # Setups
  
  def create_empty(context \\ %{}) do
    {:ok, animals: %{}}
  end

  def add_animal %{animals: animals} do
    {new_animals, _} = api_create(animals, @new_animal)
    {:ok, animals: new_animals}
  end

  # Test

  describe "empty" do 
    setup :create_empty

    test "creation returns id", %{animals: animals} do
      {animals, id} = api_create(animals, @new_animal)
      assert id  == 1
      assert Map.size(animals) == 1
    end
  end
  
  describe "a fresh animal" do
    setup [:create_empty, :add_animal]

    test "what the retrieved animal looks like", %{animals: animals} do
      [animal] = VersionedAnimal.all(animals, @middle_date)
      
      assert animal.id == 1
      assert animal.version == 1
      assert animal.name == @new_animal["name"]
      assert animal.species == @new_animal["species"]
      assert animal.tags == @new_animal["tags"]
      assert animal.int_properties == @new_animal["int_properties"]
      assert animal.bool_properties == @new_animal["bool_properties"]
      assert animal.string_properties == @new_animal["string_properties"]
      assert animal.creation_date == @middle_date
    end

    test "`all` doesn't return the animal if it hasn't been created yet", %{animals: animals} do
      [] = VersionedAnimal.all(animals, @early_date)
    end

    test "boundaries", %{animals: animals} do
      [] = VersionedAnimal.all(animals, Timex.shift(@middle_date, days: -1))
      [animal] = VersionedAnimal.all(animals, Timex.shift(@middle_date, days: 0))
      [animal] = VersionedAnimal.all(animals, Timex.shift(@middle_date, days: 1))
    end
  end

  describe "updating an animal" do
  end

end
