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
  
  @jake %Animal{ version: 1,
                 base: %Base{id: 2,
                             name: "Jake", 
                             species: "equine", 
                             tags: [ "gelding" ],
                             int_properties: %{},
                             bool_properties: %{"Available" => [true, ""]},
                             string_properties: %{ },
                             creation_date: Timex.to_date({2016, 1, 3})
                 },
                 deltas: []
  }
  
  @ross %Animal{ version: 1,
                 base: %Base{id: 3,
                             name: "ross", 
                             species: "equine", 
                             tags: [ "stallion", "aggressive" ],
                             int_properties: %{},
                             bool_properties: %{"Available" => [true, ""]},
                             string_properties: %{ "Primary billing" => ["Marick", ""]},
                             creation_date: Timex.to_date({2016, 1, 3})
                 },
                 deltas: []
  }
  
  @xena %Animal{ version: 1,
                 base: %Base{id: 4,
                             name: "Xena", 
                             species: "equine", 
                             tags: [ "mare", "skittish" ],
                             int_properties: %{},
                             bool_properties: %{"Available" => [false, "off for the summer"]},
                             string_properties: %{ "Primary billing" => ["Marick", ""]},
                             creation_date: Timex.to_date({2016, 1, 3})
                 },
                 deltas: []
  }
  
  @newbie %Animal{ version: 1,
                   base: %Base{id: 5,
                               name: "Newbie (as of 2018)", 
                               species: "equine", 
                               tags: [ "mare", "skittish" ],
                               int_properties: %{},
                               bool_properties: %{"Available" => [true, ""]},
                               string_properties: %{ "Primary billing" => ["Marick", ""]},
                               creation_date: Timex.to_date({2018, 1, 1})
                   },
                   deltas: []
  }
  
  
  def all(date) do
    GenServer.call(__MODULE__, [:all, date])
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
      @athena.base.id => @athena,
      @jake.base.id => @jake,
      @ross.base.id => @ross,
      @xena.base.id => @xena,
      @newbie.base.id => @newbie
    }
    
    {:ok, animals}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :_ignore, name: name) 
  end

  def handle_call([:all, show_as_of_date], _from, state) do
    Apex.ap show_as_of_date
    acceptable = fn (candidate) ->
      Apex.ap candidate.base.creation_date
      Apex.ap Date.compare(candidate.base.creation_date, show_as_of_date)
      Date.compare(candidate.base.creation_date, show_as_of_date) != :gt
    end

    accepted = Map.values(state) |> Enum.filter(acceptable)
    
    {:reply, accepted, state}
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
