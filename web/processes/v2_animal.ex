defmodule Eecrit.VersionedAnimal do
  defstruct original: nil, updates: nil, latest_version: 1

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
      effective_date: nil
    use ExConstructor
  end

  alias Eecrit.VersionedAnimal.Private, as: P
  defmodule Private do
    def snapshot_no_later_than([], date), do: nil

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
  end

  def create(animals, params) do
    new_id = Map.size(animals) + 1

    original =
      params
      |> Map.merge(%{"id" => new_id})
      |> Snapshot.new

    versioned = %VersionedAnimal{
      original: original,
      updates: [],
      latest_version: 1
    }

    new_animals = Map.put(animals, new_id, versioned)
    {new_animals, new_id}
  end


  def update(animals, updated_params) do
    id = updated_params["id"]
    snapshot = Snapshot.new(updated_params)

    with_update_applied = update_in animals[id].updates, fn(snapshots) ->
      P.add_snapshot(snapshots, snapshot)
    end

    update_in with_update_applied[id].latest_version, &(&1 + 1)
  end

  def all(animals, as_of_date) do
    acceptable = fn (candidate) ->
      P.candidate_exists_as_of_date(candidate.original.effective_date, as_of_date)
    end
    Map.values(animals)
    |> Enum.filter(acceptable)
    |> Enum.map(&(select_snapshot(&1, as_of_date)))
  end

  def select_snapshot(versioned_animal, as_of_date) do
    suitable_update =
      P.snapshot_no_later_than(versioned_animal.updates, as_of_date)
    snapshot = suitable_update || versioned_animal.original
    Map.put(snapshot, :version, versioned_animal.latest_version)
  end
end
