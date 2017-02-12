Code.require_file("v2_animal_data.exs", __DIR__)

defmodule Eecrit.V2AnimalPrivateTest do
  use ExUnit.Case, async: true
  alias Eecrit.VersionedAnimal.Private, as: P
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

    test "snapshots are kept in descending sorted order" do
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

  describe "converting an initial snapshot into a history entry" do
    test "it contains the initial name" do
      snapshot = Data.snapshot(name: "name")
      result = P.snapshot_to_history_entry(snapshot)
      assert result[:name_change] == snapshot.name
    end

    test "it shows all tags as additions" do
      snapshot = Data.snapshot(tags: ["1", "2"])
      result = P.snapshot_to_history_entry(snapshot)
      assert result[:new_tags] == snapshot.tags
    end
    
    test "there are no deletions" do
      snapshot = Data.snapshot
      result = P.snapshot_to_history_entry(snapshot)
      assert result[:deleted_tags] == []
    end

    test "the effective date is included" do
      snapshot = Data.snapshot(effective_date: Data.middle_date)
      result = P.snapshot_to_history_entry(snapshot)
      assert result[:effective_date] == snapshot.effective_date
    end

    test "audit data is included" do
      snapshot = Data.snapshot(audit_date: Data.middle_date, audit_author: "m")
      result = P.snapshot_to_history_entry(snapshot)
      assert result[:audit_date] == snapshot.audit_date
      assert result[:audit_author] == snapshot.audit_author
    end
  end

  describe "diffing snapshots" do
    test "names can differ" do 
      one = Data.snapshot(name: "one")
      two = Data.snapshot(name: "two")
      
      result = P.snapshot_diffs_to_history_entry(one, two)
      assert result[:name_change] == two.name
    end
    
    test "... or names can be unchanged" do 
      one = Data.snapshot(name: "same")
      two = Data.snapshot(name: "same")
      
      result = P.snapshot_diffs_to_history_entry(one, two)
      assert result[:name_change] == nil
    end

    test "tags will often be unchanged" do
      one = Data.snapshot(tags: ["a"])
      two = Data.snapshot(tags: ["a"])

      result = P.snapshot_diffs_to_history_entry(one, two)
      assert result[:new_tags] == [] 
      assert result[:deleted_tags] == []
    end

    test "tags can be added" do
      one = Data.snapshot(tags: ["c"])
      two = Data.snapshot(tags: ["z", "m", "c", "a", "f"])

      result = P.snapshot_diffs_to_history_entry(one, two)
      assert result[:new_tags] == ["z", "m", "a", "f"] 
      assert result[:deleted_tags] == []
    end

    test "tags can be removed" do
      one = Data.snapshot(tags: ["c", "d"])
      two = Data.snapshot(tags: ["c"])

      result = P.snapshot_diffs_to_history_entry(one, two)
      assert result[:new_tags] == [] 
      assert result[:deleted_tags] == ["d"]
    end

    test "... or both" do
      one = Data.snapshot(tags: ["c", "d"])
      two = Data.snapshot(tags: ["c", "e"])

      result = P.snapshot_diffs_to_history_entry(one, two)
      assert result[:new_tags] == ["e"] 
      assert result[:deleted_tags] == ["d"]
    end


    test "the effective date of the diff is that of the second snapshot" do
      one = Data.snapshot(effective_date: Data.early_date)
      two = Data.snapshot(effective_date: Data.middle_date)

      result = P.snapshot_diffs_to_history_entry(one, two)
      assert result[:effective_date] == Data.middle_date
    end

    test "ditto for the audit material" do
      one = Data.snapshot(audit_date: Data.early_date, audit_author: "early")
      two = Data.snapshot(audit_date: Data.middle_date, audit_author: "later")
      result = P.snapshot_diffs_to_history_entry(one, two)
      assert result[:audit_date] == two.audit_date
      assert result[:audit_author] == two.audit_author
    end
  end
end
