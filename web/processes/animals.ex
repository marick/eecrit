defmodule Eecrit.Animals do
  use GenServer

  @athena %{ id: 1,
             version: 1,
             name: "Athena", 
             species: "bovine", 
             tags: [ "cow" ],
             int_properties: %{},
             bool_properties: %{"Available" => [true, ""]},
             string_properties: %{ "Primary billing" => ["CSR", ""]},
  }
  
  @jake %{ id: 2, 
           version: 1,
           name: "Jake", 
           species: "equine", 
           tags: [ "gelding" ],
           int_properties: %{},
           bool_properties: %{"Available" => [true, ""]},
           string_properties: %{ },
  }
  
  @ross %{ id: 3, 
           version: 1,
           name: "ross", 
           species: "equine", 
           tags: [ "stallion", "aggressive" ],
           int_properties: %{},
           bool_properties: %{"Available" => [true, ""]},
           string_properties: %{ "Primary billing" => ["Marick", ""]},
  }
  
  @xena %{ id: 4, 
           version: 1,
           name: "Xena", 
           species: "equine", 
           tags: [ "mare", "skittish" ],
           int_properties: %{},
           bool_properties: %{"Available" => [false, "off for the summer"]},
           string_properties: %{ "Primary billing" => ["Marick", ""]},
  }

  use GenServer

  def all() do 
    GenServer.call(__MODULE__, :all)
  end

  # Behind the scenes

  def init(_) do
    animals = %{
      @athena.id => @athena,
      @jake.id => @jake,
      @ross.id => @ross,
      @xena.id => @xena,
    }
    
    {:ok, animals}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, :_ignore, name: name) 
  end

  def handle_call(:all, _from, state) do 
    {:reply, Map.values(state), state}
  end
end
