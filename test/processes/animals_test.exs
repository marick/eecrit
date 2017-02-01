defmodule Eecrit.AnimalsTest do
  use ExUnit.Case, async: true
  alias Eecrit.Animals
  alias Eecrit.AnimalDeltas

  setup do
    {:ok, animals} = Animals.start_link(:_unused_name)
    {:ok, animals: animals}
  end

  @starting_count 5
  
  test "initialized", %{animals: animals} do
    assert Enum.count(Animals.all(~D[2100-01-01])) == @starting_count
  end

  @new_animal %{"name" => "new animal", 
                "species" => "equine", 
                "tags" => [ "stallion", "aggressive" ],
                "int_properties" => %{"val" => [1, "x"]},
                "bool_properties" => %{"Available" => [true, ""]},
                "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
                "creation_date" => "2015-03-01T04:50:34-05:00Z"
  }
  
  test "adding an animal", %{animals: animals} do
    {:ok, %{originalId: "original", serverId: @starting_count+1}} =
      Animals.create("original", @new_animal)

  end
end
