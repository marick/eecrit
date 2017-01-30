defmodule Eecrit.Animals do
  use GenServer
  alias Eecrit.V2Animal, as: Animal
  alias Eecrit.V2Animal.Base, as: Base
  use Timex

  @athena %Animal{ version: 1,
                   base: %Base{id: 1,
                               name: "Athena", 
                               species: "bovine", 
                               tags: [ "cow" ],
                               int_properties: %{},
                               bool_properties: %{"Available" => [true, ""]},
                               string_properties: %{ "Primary billing" => ["CSR", ""]},
                               creation_date: Timex.to_date({2015, 12, 3})
                   },
                   deltas: []
  }
  
  # @jake %{ id: 2, 
  #          version: 1,
  #          name: "Jake", 
  #          species: "equine", 
  #          tags: [ "gelding" ],
  #          int_properties: %{},
  #          bool_properties: %{"Available" => [true, ""]},
  #          string_properties: %{ },
  # }
  
  # @ross %{ id: 3, 
  #          version: 1,
  #          name: "ross", 
  #          species: "equine", 
  #          tags: [ "stallion", "aggressive" ],
  #          int_properties: %{},
  #          bool_properties: %{"Available" => [true, ""]},
  #          string_properties: %{ "Primary billing" => ["Marick", ""]},
  # }
  
  # @xena %{ id: 4, 
  #          version: 1,
  #          name: "Xena", 
  #          species: "equine", 
  #          tags: [ "mare", "skittish" ],
  #          int_properties: %{},
  #          bool_properties: %{"Available" => [false, "off for the summer"]},
  #          string_properties: %{ "Primary billing" => ["Marick", ""]},
  # }

  use GenServer

  def all() do 
    GenServer.call(__MODULE__, :all)
  end

  def create(original_id, animal) do 
    GenServer.call(__MODULE__, [:create, original_id, animal])
  end

  def update(animal) do 
    GenServer.call(__MODULE__, [:update, animal])
  end

  # Behind the scenes

  def init(_) do
    animals = %{
      @athena.base.id => @athena
      # @jake.id => @jake,
      # @ross.id => @ross,
      # @xena.id => @xena,
    }
    
    {:ok, animals}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :_ignore, name: name) 
  end

  def handle_call(:all, _from, state) do 
    {:reply, Map.values(state), state}
  end

  def handle_call([:update, animal = %{"id" => id}],
                  _from, state) do
    new_state = Map.put(state, id, animal)
    retval = %{id: id}
    {:reply, {:ok, retval}, new_state}
  end

  def handle_call([:create, original_id, animal], _from, state) do
    new_id = Map.size(state) + 100  # temp
    new_state = Map.put(state, new_id, animal)
    retval = %{originalId: original_id, serverId: new_id}
    {:reply, {:ok, retval}, new_state}
  end
end
