defmodule Eecrit.AnimalsProcessTest do
  use ExUnit.Case, async: true
  alias Eecrit.AnimalsProcess
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
                "creation_date" => @middle_date,
                "effective_date" => @middle_date
  }

  @expected_id 1

  # Setups
  
  # def create_empty(context \\ %{}) do
  #   {:ok, pid} = AnimalsProcess.start_link(:_private_to_animal_server_test, :empty)
  #   {:ok, pid: pid}
  # end

  # def add_animal %{pid: pid} do
  #   AnimalsProcess.create(@new_animal, pid)
  #   :ok
  # end
    

  # describe "startup" do
  #   test "initialized empty" do
  #     {:ok, pid} = AnimalsProcess.start_link(:_private_to_animal_server_test, :empty)
  #     [] = AnimalsProcess.all(@latest_date, pid)
  #   end
  # end
  
  # describe "empty" do 
  #   setup :create_empty
  
  #   test "creation returns ids", %{pid: pid} do
  #     {:ok, server_id} = AnimalsProcess.create(@new_animal, pid)

  #     assert server_id == @expected_id
  #   end
  # end
  
  # describe "creating a fresh animal" do
  #   setup [:create_empty, :add_animal]
  #   # Note: other variants are tested elsewhere.

  #   test "what the retrieved animal looks like", %{pid: pid} do
  #     [animal] = AnimalsProcess.all(@latest_date, pid)
      
  #     assert animal.id == @expected_id
  #     assert animal.version == 1
  #     assert animal.name == @new_animal["name"]
  #     assert animal.species == @new_animal["species"]
  #     assert animal.tags == @new_animal["tags"]
  #     assert animal.int_properties == @new_animal["int_properties"]
  #     assert animal.bool_properties == @new_animal["bool_properties"]
  #     assert animal.string_properties == @new_animal["string_properties"]
  #     assert animal.creation_date == @middle_date
  #   end
    
  #   test "that `all` obeys the date", %{pid: pid} do
  #     assert [] == AnimalsProcess.all(@early_date, pid)
  #   end
  # end

  # describe "adding an animal" do 
  #   setup [:create_empty, :add_animal]

  #   test "update returns the id of the updated animal" do
  #     updated_animal =
  #       @new_animal
  #       |> Map.put("id", @expected_id)
  #       |> Map.put("version", 2)
  #       |> Map.put("creation_date", @later_date)

  #     {:ok, @expected_id} = AnimalsProcess.update(@new_animal, updated_animal)
  #   end
  # end    
end
