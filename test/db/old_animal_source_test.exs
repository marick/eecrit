defmodule Eecrit.OldAnimalSourceTest do
  use Eecrit.ModelCase
  alias Eecrit.OldAnimalSource, as: S


  def names(animals), do: Enum.map(animals, &Map.get(&1, :name))

  test "all_ordered uses human alphabeticization" do
    insert_old_animal(name: "ab")
    insert_old_animal(name: "AA")
    insert_old_animal(name: "Z")
    insert_old_animal(name: "m")
    insert_old_animal(name: "12")
    
    assert names(S.all_ordered) == ["12", "AA", "ab", "m", "Z"]
  end
  
  describe "all_ordered and time values" do
    setup do 
      yesterday = Timex.shift(Timex.today, days: -1) |> Ecto.Date.cast!
      today = Timex.today |> Ecto.Date.cast!
      tomorrow = Timex.shift(Timex.today, days: 1) |> Ecto.Date.cast!
      insert_old_animal(name: "never", date_removed_from_service: nil)
      insert_old_animal(name: "yesterday", date_removed_from_service: yesterday)
      insert_old_animal(name: "today", date_removed_from_service: today)
      insert_old_animal(name: "tomorrow", date_removed_from_service: tomorrow)

      provides([yesterday, today, tomorrow])
    end

    test "what about out-of-service animals?" do
      # By default, they are returned
      actual = names(S.all_ordered)
      assert actual == ["never", "today", "tomorrow", "yesterday"]

      # ... which can also be asked for explicitly
      actual = names(S.all_ordered(include_out_of_service: true))
      assert actual == ["never", "today", "tomorrow", "yesterday"]

      # This can be overridden.
      # Note that animals are removed from service at the start of the day
      actual = names(S.all_ordered(include_out_of_service: false))
      assert actual  == ["never", "tomorrow"]
    end

    test "only including animals in service any time during a range", c do
      assert names(S.all_ordered(ever_in_service_during: {c.yesterday, c.tomorrow})) ==
        ["never", "today", "tomorrow", "yesterday"]
      # Anything available for part of the range is returned.
      assert names(S.all_ordered(ever_in_service_during: {c.today, c.tomorrow})) ==
        ["never", "today", "tomorrow"]
      assert names(S.all_ordered(ever_in_service_during: {c.yesterday, c.today})) ==
        ["never", "today", "tomorrow", "yesterday"]
    end
  end
end
