defmodule Eecrit.Animals do
  use GenServer
  alias Eecrit.V2Animal, as: Animal
  alias Eecrit.V2Animal.Base, as: Base
  use Timex

  @athena %{"name" => "Athena", 
            "species" => "bovine", 
            "tags" => [ "cow" ],
            "int_properties" => %{},
            "bool_properties" => %{"Available" => [true, ""]},
            "string_properties" =>  %{ "Primary billing" => ["CSR", ""]},
            "creation_date" => "2015-03-01T04:50:34-05:00Z"
  }
  
  @jake %{"name" => "Jake", 
          "species" => "equine", 
          "tags" => [ "gelding" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [true, ""]},
          "string_properties" =>  %{ },
          "creation_date" => "2015-03-01T04:50:34-05:00Z"
  }
  
  @ross %{"name" => "ross", 
          "species" => "equine", 
          "tags" => [ "stallion", "aggressive" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [true, ""]},
          "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
          "creation_date" => "2015-03-01T04:50:34-05:00Z"
  }
  
  @xena %{"name" => "Xena", 
          "species" => "equine", 
          "tags" => [ "mare", "skittish" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [false, "off for the summer"]},
          "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
          "creation_date" => "2015-03-01T04:50:34-05:00Z"
  }
  
  @newbie %{"name" => "2018", 
            "species" =>  "equine", 
            "tags" =>  [ "mare", "skittish" ],
            "int_properties" =>  %{},
            "bool_properties" =>  %{"Available" => [true, ""]},
            "string_properties" => %{ "Primary billing" => ["Marick", ""]},
            "creation_date" => "2018-01-01T04:50:34-05:00Z"
  }

  def all(date) do
    GenServer.call(__MODULE__, [:all, date])
  end

  def get(id) do 
    GenServer.call(__MODULE__, [:get, id])
  end
  
  def create(original_id, animal) do 
    GenServer.call(__MODULE__, [:create, original_id, animal])
  end

  def update(animal) do 
    GenServer.call(__MODULE__, [:update, animal])
  end

  # Behind the scenes

  def init(_) do
    sources = [@athena, @jake, @ross, @xena, @newbie]
    reducer = fn(e, acc) ->
      {_, acc} = create_and_add(acc, e)
      acc
    end
    
    {:ok, Enum.reduce(sources, %{}, reducer)}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :_ignore, name: name) 
  end

  def handle_call([:all, show_as_of_date], _from, state) do
    acceptable = fn (candidate) ->
      Date.compare(candidate.base.creation_date, show_as_of_date) != :gt
    end

    accepted = Map.values(state) |> Enum.filter(acceptable)
    
    {:reply, accepted, state}
  end

  def handle_call([:get, id], _from, state) do
    animal = Map.fetch!(state, id)
    {:reply, animal, state}
  end

  def handle_call([:update, animal = %{"id" => id}],
                  _from, state) do
    new_state = Map.put(state, id, animal)
    retval = %{id: id}
    {:reply, {:ok, retval}, new_state}
  end

  def handle_call([:create, original_id, base_animal], _from, state) do
    {new_id, new_state} = create_and_add(state, base_animal)
    retval = %{originalId: original_id, serverId: new_id}
    {:reply, {:ok, retval}, new_state}
  end

  # Util

  def create_and_add(state, base_animal) do 
    new_id = Map.size(state) + 1

    animal = %Animal{ version: 1,
                      base: %Base{id: new_id,
                                  name: base_animal["name"],
                                  species: base_animal["species"], 
                                  tags: base_animal["tags"], 
                                  int_properties: base_animal["int_properties"],
                                  bool_properties: base_animal["bool_properties"],
                                  string_properties: base_animal["string_properties"],
                                  creation_date: to_date(base_animal["creation_date"])
                      },
                      deltas: []
                    }
    new_state = Map.put(state, new_id, animal)
    
    {new_id, new_state}
  end


  def to_date(incoming) do
    incoming |> Timex.parse!("{ISO:Extended}") |> Timex.to_date
  end
end
