Code.require_file "v2_animal_data.exs", __DIR__

defmodule Eecrit.V2AnimalPrivateTest do
  use ExUnit.Case, async: true
  alias Eecrit.VersionedAnimal.Private, as: P
  alias Eecrit.V2AnimalData, as: Data
  use Timex


  describe "creating deltas" do
    test "no change" do
      original = Data.snapshot(id: 1, creation_date: Data.middle_date)
      new = Data.snapshot(id: 1, creation_date: Data.middle_latest_date)
      result = P.generate_delta(original, new)
      assert result.date_of_change == Data.middle_latest_date
      assert result.name_change == nil
      assert result.tag_edits == [eq: original.tags]
    end

    test "name change" do
      original = Data.snapshot(id: 1, creation_date: Data.middle_date)
      new = Data.snapshot(id: 1, name: "DERP!", creation_date: Data.middle_latest_date)
      result = P.generate_delta(original, new)
      assert result.date_of_change == Data.middle_latest_date
      assert result.name_change == "DERP!"
      assert result.tag_edits == [eq: original.tags]
    end      

    test "tag change" do
      original = Data.snapshot(id: 1,
        tags: ["delete", "stay"],
        creation_date: Data.middle_date)
      new = Data.snapshot(id: 1,
        name: "DERP!",
        tags: ["stay", "add"],
        creation_date: Data.middle_latest_date)
      result = P.generate_delta(original, new)
      assert result.date_of_change == Data.middle_latest_date
      assert result.name_change == "DERP!"
      assert result.tag_edits ==
        [del: ["delete"],
         eq: ["stay"],
         ins: ["add"]]
    end
  end

  test "applying tag edits" do
    assert P.construct_tags([]) == []
    
    same = List.myers_difference(["a"], ["a"])
    assert P.construct_tags(same) == ["a"]
    
    addition = List.myers_difference(["a"], ["a", "b"])
    assert P.construct_tags(addition) == ["a", "b"]
    
    deletion = List.myers_difference(["a", "b"], ["b"])
    assert P.construct_tags(addition) == ["a", "b"]
    
    for_the_heck_of_it = List.myers_difference(
      ["a", "b",      "d", "e"],
      [     "b", "c",      "e", "f"])
    assert P.construct_tags(for_the_heck_of_it) == [     "b", "c",      "e", "f"]
  end

  describe "applying deltas" do
    setup do
      original = Data.snapshot(id: 1, name: "start", tags: ["keep", "delete"],
        creation_date: Data.early_middle_date)
      name_change = Data.snapshot(id: 1, name: "change1", tags: ["keep", "delete"],
        creation_date: Data.middle_date)
      tag_change = Data.snapshot(id: 1, name: "change1", tags: ["keep"],
        creation_date: Data.middle_latest_date)
      both_change = Data.snapshot(id: 1, name: "change_b", tags: ["keep", "add"],
        creation_date: Data.latest_date)

      name_change_delta = P.generate_delta(original, name_change)
      tag_change_delta = P.generate_delta(name_change, tag_change)
      both_change_delta = P.generate_delta(tag_change, both_change)
        
      {:ok, %{base: original,
              name_change: name_change_delta,
              tag_change: tag_change_delta,
              both_change: both_change_delta,
              all_deltas: [name_change_delta, tag_change_delta, both_change_delta],
             }
      }
    end

    test "name change", %{base: base, name_change: name_change} do
      result = P.apply_deltas(base, [name_change])
      assert result.name == "change1"
      assert result.tags == base.tags
    end

    test "add tag change", %{base: base, name_change: name_change, tag_change: tag_change} do
      result = P.apply_deltas(base, [name_change, tag_change])
      assert result.name == "change1"
      assert result.tags == ["keep"]
    end

    test "full change", %{base: base, all_deltas: all_deltas} do
      result = P.apply_deltas(base, all_deltas)
      assert result.name == "change_b"
      assert result.tags == ["keep", "add"]
    end

    test "can select a subset of deltas", %{all_deltas: all_deltas} do
      assert P.deltas_no_later_than(all_deltas, Data.early_date) == []
      assert P.deltas_no_later_than(all_deltas, Data.early_middle_date) == []
      # First delta created on middle date
      assert P.deltas_no_later_than(all_deltas, Data.middle_date)
      == Enum.take(all_deltas, 1)
      assert P.deltas_no_later_than(all_deltas, Data.middle_latest_date)
      == Enum.take(all_deltas, 2)
      assert P.deltas_no_later_than(all_deltas, Data.latest_date)
      == Enum.take(all_deltas, 3)
    end
  end
end
  
