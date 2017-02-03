defmodule Eecrit.VersionedAnimal do
  defstruct version: 1, base: nil, deltas: []

  defmodule Snapshot do
    defstruct id: nil,
      name: nil,
      species: nil,
      tags: [],
      int_properties: %{},
      bool_properties: %{},
      string_properties: %{},
      creation_date: nil
  end

  defmodule Delta do
    defstruct updated_at: nil,
      name_change: nil,
      tag_additions: [],
      tag_subtractions: []
  end

  def create(animals, params) do
    new_id = Map.size(animals) + 1
    
    animal = %Eecrit.VersionedAnimal{version: 1,
                                     base: fresh_snapshot(params, new_id),
                                     deltas: []}
    new_animals = Map.put(animals, new_id, animal)
    {new_animals, new_id}
  end


  def update(animals, original_params, updated_params) do
    original = fresh_snapshot(original_params)
    updated = fresh_snapshot(updated_params)

    Map.put(animals, updated.id, updated)
  end

  def all(animals, as_of_date) do
    acceptable = fn (candidate) ->
      Date.compare(candidate.base.creation_date, as_of_date) != :gt
    end

    Map.values(animals)
    |> Enum.filter(acceptable)
    |> Enum.map(&export/1)
  end    


  # Eventually, this will be done with changesets - and maybe in a different module.
  defp fresh_snapshot(params, id \\ "irrelevant") do
    %Snapshot{id: id,
              name: params["name"],
              species: params["species"], 
              tags: params["tags"], 
              int_properties: params["int_properties"],
              bool_properties: params["bool_properties"],
              string_properties: params["string_properties"],
              creation_date: params["creation_date"]
    }
  end
              
  def export(animal) do
    Map.put(animal.base, :version, animal.version)
  end
end
