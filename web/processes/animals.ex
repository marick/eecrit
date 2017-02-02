defmodule Eecrit.Animals do
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

  def all(date) do
    GenServer.call(__MODULE__, [:all, date])
  end

  def get(id) do 
    GenServer.call(__MODULE__, [:get, id])
  end
  
  def create(animal, original_id) do 
    GenServer.call(__MODULE__, [:create, animal, original_id])
  end

  def update(animal) do 
    GenServer.call(__MODULE__, [:update, animal])
  end

  # Behind the scenes

  def init(how) do
    sources = [@athena, @jake, @ross, @xena, @newbie]
    reducer = fn(e, acc) ->
      {_, acc} = create_and_add(acc, e)
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


  def handle_call([:all, show_as_of_date], _from, state) do
    acceptable = fn (candidate) ->
      Apex.ap {candidate.base.creation_date, show_as_of_date}
      Date.compare(candidate.base.creation_date, show_as_of_date) != :gt
    end

    accepted = Map.values(state) |> Enum.filter(acceptable) |> Enum.map(&VersionedAnimal.export/1)
    
    {:reply, accepted, state}
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
    {new_id, new_state} = create_and_add(state, base_animal)
    retval = %{originalId: original_id, serverId: new_id}
    {:reply, {:ok, retval}, new_state}
  end

  # Util

  def create_and_add(state, base_animal) do
    new_id = Map.size(state) + 1

    animal = %VersionedAnimal{ version: 1,
                      base: %Snapshot{id: new_id,
                                  name: base_animal["name"],
                                  species: base_animal["species"], 
                                  tags: base_animal["tags"], 
                                  int_properties: base_animal["int_properties"],
                                  bool_properties: base_animal["bool_properties"],
                                  string_properties: base_animal["string_properties"],
                                  creation_date: base_animal["creation_date"]
                      }, 
                      deltas: []
                    }
    new_state = Map.put(state, new_id, animal)
    
    {new_id, new_state}
  end
end
