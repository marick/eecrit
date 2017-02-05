Code.require_file("v2_animal_data.exs", __DIR__)

defmodule Eecrit.V2AnimalPrivateTest do
  use ExUnit.Case, async: true
  alias Eecrit.VersionedAnimal.Private, as: P
  alias Eecrit.VersionedAnimal
  alias Eecrit.VersionedAnimal.Snapshot
  alias Eecrit.V2AnimalData, as: Data
  use Timex

  describe "selection" do 
    test "nothing to select" do
      assert P.snapshot_no_later_than([], Data.early_date) == nil
    end

    test "all snapshots in the list are later than the date" do
      no = Snapshot.new(effective_date: Data.latest_date)
      assert P.snapshot_no_later_than([no], Data.middle_latest_date) == nil
    end

    test "finds a snapshot that's just on the date" do
      yes = Snapshot.new(effective_date: Data.middle_latest_date)
      assert P.snapshot_no_later_than([yes], Data.middle_latest_date) == yes
    end

    test "finds a snapshot that's earlier than the date" do
      yes = Snapshot.new(effective_date: Data.middle_latest_date)
      assert P.snapshot_no_later_than([yes], Data.latest_date) == yes
    end

    test "find the MOST RECENT snapshot that's earlier than the date" do
      earliest = Snapshot.new(effective_date: Data.early_date)
      middlest = Snapshot.new(effective_date: Data.middle_date)
      latest = Snapshot.new(effective_date: Data.latest_date)

      list = [latest, middlest, earliest]
      assert P.snapshot_no_later_than(list, Data.early_date) == earliest
      assert P.snapshot_no_later_than(list, Data.early_middle_date) == earliest
      assert P.snapshot_no_later_than(list, Data.middle_date) == middlest
      assert P.snapshot_no_later_than(list, Data.middle_latest_date) == middlest
      assert P.snapshot_no_later_than(list, Data.latest_date) == latest
    end
  end

  describe "maintaining ordered lists" do
    test "add to an empty list" do
      only = Snapshot.new(%{})
      assert P.add_snapshot([], only) == [only]
    end

    test "snapshots are keyt in descending sorted order" do
      later = Snapshot.new(effective_date: Data.latest_date)
      early = Snapshot.new(effective_date: Data.early_date)
      middle = Snapshot.new(effective_date: Data.middle_date)

      result =
        []
        |> P.add_snapshot(later)
        |> P.add_snapshot(early)
        |> P.add_snapshot(middle)

      assert result == [later, middle, early]

      # Just for laughs, ensure that starting ordered works
      result =
        []
        |> P.add_snapshot(early)
        |> P.add_snapshot(middle)
        |> P.add_snapshot(later)

      assert result == [later, middle, early]
    end

    test "a new snapshot from the same date replaces the existing one" do
      
      later = Snapshot.new(effective_date: Data.latest_date)
      early = Snapshot.new(effective_date: Data.early_date)
      replaced = Snapshot.new(effective_date: Data.middle_date, name: "replaced")
      replacer = Snapshot.new(effective_date: Data.middle_date, name: "replacer")

      result =
        []
        |> P.add_snapshot(early)
        |> P.add_snapshot(replaced)
        |> P.add_snapshot(later)
        |> P.add_snapshot(replacer)
      
      assert result == [later, replacer, early]

      # Just for laughs 
      result =
        []
        |> P.add_snapshot(later)
        |> P.add_snapshot(early)
        |> P.add_snapshot(replaced)
        |> P.add_snapshot(replacer)
      
      assert result == [later, replacer, early]

      result =
        []
        |> P.add_snapshot(replaced)
        |> P.add_snapshot(later)
        |> P.add_snapshot(early)
        |> P.add_snapshot(replacer)
      
      assert result == [later, replacer, early]

    end
    
  end
  
end
