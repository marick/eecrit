defmodule Eecrit.AnimalsProcess do
  use GenServer
  alias Eecrit.VersionedAnimal
  alias Eecrit.VersionedAnimal.Snapshot, as: Snapshot

  @athena %{"name" => "Athena", 
            "species" => "bovine", 
            "tags" => [ "cow" ],
            "int_properties" => %{},
            "bool_properties" => %{"Available" => [true, ""]},
            "string_properties" =>  %{ "Primary billing" => ["CSR", ""]},
            "creation_date" => ~D[2015-03-01]
  }
  
  @jake %{"name" => "Jake", 
          "species" => "equine", 
          "tags" => [ "gelding" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [true, ""]},
          "string_properties" =>  %{ },
          "creation_date" => ~D[2015-03-01]
  }
  
  @ross %{"name" => "ross", 
          "species" => "equine", 
          "tags" => [ "stallion", "aggressive" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [true, ""]},
          "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
          "creation_date" => ~D[2015-03-01]
  }
  
  @xena %{"name" => "Xena", 
          "species" => "equine", 
          "tags" => [ "mare", "skittish" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [false, "off for the summer"]},
          "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
          "creation_date" => ~D[2015-03-01]
  }
  
  @newbie %{"name" => "2018", 
            "species" =>  "equine", 
            "tags" =>  [ "mare", "skittish" ],
            "int_properties" =>  %{},
            "bool_properties" =>  %{"Available" => [true, ""]},
            "string_properties" => %{ "Primary billing" => ["Marick", ""]},
            "creation_date" => ~D[2018-03-01]
  }

  def all(date, pid \\ __MODULE__) do
    GenServer.call(pid, [:all, date])
  end

  def create(animal, original_id, pid \\ __MODULE__) do 
    GenServer.call(pid, [:create, animal, original_id])
  end

  def update(animal, pid \\ __MODULE__) do 
    GenServer.call(pid, [:update, animal])
  end

  # Behind the scenes

  def init(how) do
    sources = [@athena, @jake, @ross, @xena, @newbie]
    reducer = fn(e, acc) ->
      {acc, _} = VersionedAnimal.create(acc, e)
      acc
    end

    initial =
      case how do
        :with_examples ->
          Enum.reduce(sources, %{}, reducer)
        :empty ->
          %{}
      end
    {:ok, initial}
  end

  def start_link(name, config) do
    GenServer.start_link(__MODULE__, config, name: name)
  end

  def handle_call([:all, as_of_date], _from, state) do
    animals = VersionedAnimal.all(state, as_of_date)
    {:reply, animals, state}
  end

  def handle_call([:get, id], _from, state) do
    animal = Map.fetch!(state, id) |> VersionedAnimal.export
    {:reply, animal, state}
  end

  def handle_call([:update, animal = %{"id" => id}],
                  _from, state) do
    new_state = Map.put(state, id, animal)
    retval = %{id: id}
    {:reply, {:ok, retval}, new_state}
  end

  def handle_call([:create, base_animal, original_id], _from, state) do
    {new_state, new_id} = VersionedAnimal.create(state, base_animal)
    retval = %{originalId: original_id, serverId: new_id}
    {:reply, {:ok, retval}, new_state}
  end

  # Util

end
