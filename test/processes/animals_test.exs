defmodule Eecrit.AnimalsTest do
  use ExUnit.Case, async: true
  alias Eecrit.Animals
  alias Eecrit.AnimalDeltas
  use Timex

  @browser_early_date  "2015-03-01T04:50:34-05:00Z"
  @browser_middle_date "2016-03-01T04:50:34-05:00Z"
  @browser_later_date  "2017-03-01T04:50:34-05:00Z"
  @browser_latest_date "2018-03-01T04:50:34-05:00Z"

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
                "creation_date" => @browser_early_date
  }

  # Setups
  
  def create_empty(context \\ %{}) do
    {:ok, pid} = Animals.start_link(:_unused_name, :empty)
    {:ok, pid: pid}
  end

  def add_animal %{pid: pid} do
    {:ok, %{originalId: "original", serverId: id}} =
      GenServer.call(pid, [:create, "original", @new_animal])

    {:ok, id: id}
  end
    

  describe "startup" do
    test "initialized empty" do
      {:ok, pid} = Animals.start_link(:_unused_name, :empty)
      [] = GenServer.call(pid, [:all, @latest_date])
    end
  end
  
  describe "empty" do 
    setup :create_empty
  
    test "creation returns ids", %{pid: pid} do
      {:ok, %{originalId: "original", serverId: server_id}} =
        GenServer.call(pid, [:create, "original", @new_animal])

      assert server_id == 1
    end
  end
  
  describe "creating a fresh animal" do
    setup [:create_empty, :add_animal]

    test "what the retrieved animal looks like", %{pid: pid, id: id} do
      animal = GenServer.call(pid, [:get, id])
      
      assert animal.id == 1
      assert animal.version == 1
      assert animal.name == @new_animal["name"]
      assert animal.species == @new_animal["species"]
      assert animal.tags == @new_animal["tags"]
      assert animal.int_properties == @new_animal["int_properties"]
      assert animal.bool_properties == @new_animal["bool_properties"]
      assert animal.string_properties == @new_animal["string_properties"]
      assert animal.creation_date == @early_date

      [animal] = GenServer.call(pid, [:all, @early_date])
    end

  end

  describe "working with a fresh animal" do
  end


  describe "updating an animal" do
  end

  describe "working with an updated animal" do
  end
  

  # test "updating an animal", %{animals: animals} do
  #   result = GenServer.call(animals, [:create, "original", @new_animal])
  #   {:ok, %{originalId: "original", serverId: server_id}} = result
  #   assert server_id == 1

  #   changed_animal = Map.merge(@new_animal, @deltas)

  #   result = GenServer.call(animals, [:update, @new_animal, changed_animal])
    
  # end

  
end
