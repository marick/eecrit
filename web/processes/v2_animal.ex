defmodule Eecrit.VersionedAnimal do
  defstruct snapshots: [], latest_version: 1, creation_date: nil

  alias Eecrit.VersionedAnimal
  alias Eecrit.VersionedAnimal.Snapshot
  
  defmodule Snapshot do
    defstruct id: nil,
      version: 1, # Set only when snapshot is externalized
      name: nil,
      species: nil,
      tags: [],
      int_properties: %{},
      bool_properties: %{},
      string_properties: %{},
      creation_date: nil,
      
      effective_date: nil,
      audit_date: nil,
      audit_author: nil
    use ExConstructor
  end

  alias Eecrit.VersionedAnimal.Private, as: P
  defmodule Private do
    def snapshot_no_later_than([], _date), do: nil

    def snapshot_no_later_than([x | xs], date) do
      if candidate_is_too_late(x.effective_date, date) do
        snapshot_no_later_than(xs, date)
      else
        x
      end
    end

    def candidate_is_too_late(candidate, date) do
      Date.compare(candidate, date) == :gt
    end

    def candidate_is_at_date(candidate, date) do
      Date.compare(candidate, date) == :eq
    end

    def candidate_exists_as_of_date(candidate, date) do
      Date.compare(candidate, date) != :gt
    end

    def add_snapshot(snapshots, new) do
      compare_by_date = fn(comparator) ->
        fn(snapshot) -> comparator.(snapshot.effective_date, new.effective_date) end
      end

      {later, not_later} =
        snapshots |> Enum.split_while(compare_by_date.(&candidate_is_too_late/2))

      {_at_date, earlier} = 
        not_later |> Enum.split_while(compare_by_date.(&candidate_is_at_date/2))

      later ++ [new] ++ earlier
    end

    def select_snapshot(versioned_animal, as_of_date) do
      snapshot =
        snapshot_no_later_than(versioned_animal.snapshots, as_of_date)
      Map.put(snapshot, :version, versioned_animal.latest_version)
    end
    
    def snapshot_to_history_entry(snapshot) do
      %{name_change: snapshot.name,
        new_tags: snapshot.tags,
        deleted_tags: [],
        effective_date: snapshot.effective_date,
        audit_date: snapshot.audit_date,
        audit_author: snapshot.audit_author,
      }
    end


    def snapshot_diffs_to_history_entry(one, two) do
      edit = List.myers_difference(one.tags, two.tags)

      new_tags = Keyword.get_values(edit, :ins) |> Enum.concat
      deleted_tags = Keyword.get_values(edit, :del) |> Enum.concat

      name_change = if one.name != two.name, do: two.name

      %{name_change: name_change,
        new_tags: new_tags,
        deleted_tags: deleted_tags,
        effective_date: two.effective_date,
        audit_date: two.audit_date,
        audit_author: two.audit_author
      }
    end
  end

  def create(animals, animal_params, metadata_params) do
    new_id = Map.size(animals) + 1

    original =
      animal_params
      |> Map.merge(%{"id" => new_id})
      |> Map.merge(metadata_params)
      |> Snapshot.new

    versioned = %VersionedAnimal{
      snapshots: [original],
      latest_version: 1,
      creation_date: original.creation_date
    }

    new_animals = Map.put(animals, new_id, versioned)
    {new_animals, new_id}
  end


  def update(animals, updated_params, metadata) do
    id = updated_params["id"]

    snapshot = 
      updated_params
      |> Map.merge(metadata)
      |> Snapshot.new
    
    with_update_applied = update_in animals[id].snapshots, fn(snapshots) ->
      P.add_snapshot(snapshots, snapshot)
    end

    update_in with_update_applied[id].latest_version, &(&1 + 1)
  end

  def all(animals, as_of_date) do
    acceptable = fn (candidate) ->
      # Note that all snapshots share the same creation date.
      creation_date = candidate.creation_date
      P.candidate_exists_as_of_date(creation_date, as_of_date)
    end
    Map.values(animals)
    |> Enum.filter(acceptable)
    |> Enum.map(&(P.select_snapshot(&1, as_of_date)))
  end

  def history(versioned_animal) do
    [initial | deltas] = snapshots = Enum.reverse(versioned_animal.snapshots)
    first_history = P.snapshot_to_history_entry(initial)
    rest_history =
      Enum.zip(snapshots, deltas)
      |> Enum.map(fn {one, two} -> P.snapshot_diffs_to_history_entry(one, two) end)
    
    [first_history | rest_history]
  end

end
