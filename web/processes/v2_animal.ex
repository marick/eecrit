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
    use ExConstructor
  end

  defmodule Delta do
    defstruct date_of_change: nil,
      name_change: nil,
      tag_edits: []
  end

  alias Private, as: P
  defmodule Private do
    def fresh_snapshot(params, id \\ "irrelevant") do
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

    def generate_delta(original, new) do
      name_change = if original.name != new.name, do: new.name
      tag_edits = List.myers_difference(original.tags, new.tags)
      
      %Delta{date_of_change: new.creation_date,
             name_change: name_change,
             tag_edits: tag_edits
      }
    end

    def construct_tags(edits) do
      Enum.reduce(edits, [], fn({instruction, value}, acc) ->
        case instruction do
          :eq -> acc ++ value    # O(n^2) yay
          :ins -> acc ++ value
          _ -> acc
        end
      end)
    end

    def apply_deltas(snapshot, deltas) do
      apply_name = fn(snapshot, delta) ->
          if delta.name_change do
            %{ snapshot | name: delta.name_change }
          else
            snapshot
          end
        end

      apply_tags = fn(snapshot, delta) ->
        %{ snapshot | tags: construct_tags(delta.tag_edits) }
      end

      Enum.reduce(deltas, snapshot, fn(x, acc) ->
        acc |> apply_name.(x) |> apply_tags.(x)
      end)
    end
  end
  

  def create(animals, params) do
    new_id = Map.size(animals) + 1
    
    animal = %Eecrit.VersionedAnimal{version: 1,
                                     base: P.fresh_snapshot(params, new_id),
                                     deltas: []}
    new_animals = Map.put(animals, new_id, animal)
    {new_animals, new_id}
  end


  def update(animals, original_params, updated_params) do
    original = P.fresh_snapshot(original_params)
    updated = P.fresh_snapshot(updated_params)

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


  def export(animal) do
    Map.put(animal.base, :version, animal.version)
  end


end
