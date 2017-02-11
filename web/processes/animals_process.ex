defmodule Eecrit.AnimalsProcess do
  use GenServer
  alias Eecrit.VersionedAnimal
  alias Eecrit.VersionedAnimal.Snapshot, as: Snapshot

  @early_animal_audit_date ~D[2016-05-12]
  @early_animal_effective_date ~D[2016-07-01]
  
  @athena %{"name" => "Athena",
            "version" => "irrelevant",
            "species" => "bovine", 
            "tags" => [ "cow" ],
            "int_properties" => %{},
            "bool_properties" => %{"Available" => [true, ""]},
            "string_properties" =>  %{ "Primary billing" => ["CSR", ""]},
            "creation_date" => @early_animal_effective_date
  }
  @meta_athena %{"effective_date" => @early_animal_effective_date,
                 "audit_author" => "marick",
                 "audit_date" => @early_animal_audit_date
  }

  
  @jake %{"name" => "Jake", 
          "version" => "irrelevant",
          "species" => "equine", 
          "tags" => [ "gelding" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [true, ""]},
          "string_properties" =>  %{ },
          "creation_date" => @early_animal_effective_date
  }
  @meta_jake %{"effective_date" => @early_animal_effective_date,
               "audit_author" => "marick",
               "audit_date" => @early_animal_audit_date
  }
  
  @ross %{"name" => "ross", 
          "version" => "irrelevant",
          "species" => "equine", 
          "tags" => [ "stallion", "aggressive" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [true, ""]},
          "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
          "creation_date" => @early_animal_effective_date
  }
  @meta_ross %{"effective_date" => @early_animal_effective_date,
               "audit_author" => "marick",
               "audit_date" => @early_animal_audit_date
  }
  
  @xena %{"name" => "Xena", 
          "version" => "irrelevant",
          "species" => "equine", 
          "tags" => [ "mare", "skittish" ],
          "int_properties" => %{},
          "bool_properties" => %{"Available" => [false, "off for the summer"]},
          "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
          "creation_date" => @early_animal_effective_date
  }
  @meta_xena %{"effective_date" => @early_animal_effective_date,
               "audit_author" => "marick",
               "audit_date" => @early_animal_audit_date
  }
  
  @later_animal_audit_date ~D[2018-03-01]
  @later_animal_effective_date ~D[2018-03-01]
  
  @newbie %{"name" => "2018", 
            "version" => "irrelevant",
            "species" =>  "equine", 
            "tags" =>  [ "mare", "skittish" ],
            "int_properties" =>  %{},
            "bool_properties" =>  %{"Available" => [true, ""]},
            "string_properties" => %{ "Primary billing" => ["Marick", ""]},
            "creation_date" => @later_animal_effective_date
  }
  @meta_newbie %{"effective_date" => @later_animal_effective_date,
                 "audit_author" => "dster",
                 "audit_date" => @later_animal_audit_date
  }
  
  def all(date, pid \\ __MODULE__) do
    GenServer.call(pid, [:all, date])
  end

  def create(animal, metadata, pid \\ __MODULE__) do 
    GenServer.call(pid, [:create, animal, metadata])
  end

  def update(updated, metadata, pid \\ __MODULE__) do 
    GenServer.call(pid, [:update, updated, metadata])
  end

  # Behind the scenes

  def init(how) do
    sources = Enum.zip([@athena, @jake, @ross, @xena, @newbie],
      [@meta_athena, @meta_jake, @meta_ross, @meta_xena, @meta_newbie])
    reducer = fn({animal, metadata}, acc) ->
      {acc, _} = VersionedAnimal.create(acc, animal, metadata)
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

  def handle_call([:create, animal, metadata], _from, state) do
    {new_state, new_id} = VersionedAnimal.create(state, animal, metadata)
    {:reply, {:ok, new_id}, new_state}
  end

  def handle_call([:update, updated_animal, metadata], _from, state) do
    new_state = VersionedAnimal.update(state, updated_animal, metadata)
    {:reply, {:ok, updated_animal["id"]}, new_state}
  end

  def handle_call([:all, as_of_date], _from, state) do
    animals = VersionedAnimal.all(state, as_of_date)
    {:reply, animals, state}
  end

  # Util

end
