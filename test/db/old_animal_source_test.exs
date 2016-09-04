defmodule Eecrit.OldAnimalSourceTest do
  use Eecrit.ModelCase
  alias Eecrit.OldAnimalSource

  def run(options),
    do: OldAnimalSource.all_ordered(options) |> Enum.map(&Map.get(&1, :name))
  
  def everything_now, do: run(include_out_of_service: true)
  def in_service_now, do: run(include_out_of_service: false)

  test "returns human-style alphabetical ordering" do
    insert_old_animal(name: "ab")
    insert_old_animal(name: "AA")
    insert_old_animal(name: "Z")
    insert_old_animal(name: "m")
    insert_old_animal(name: "12")
    
    assert everything_now == ["12", "AA", "ab", "m", "Z"]
    
    # With this data, no difference between two ways of calling
    assert in_service_now == ["12", "AA", "ab", "m", "Z"]
  end
  
  describe "time_based return values" do
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

    test "does not return items that are out of service at the current moment" do
      # Note that animals are removed from service at the start of the day
      assert in_service_now == ["never", "tomorrow"]

      # But everything_now can be returned
      assert everything_now == ["never", "today", "tomorrow", "yesterday"]
    end

    test "service overlap", c do
      assert run(date_range: {c.yesterday, c.tomorrow}) ==
        ["never", "today", "tomorrow", "yesterday"]
      # Anything available for part of the range is returned.
      assert run(date_range: {c.today, c.tomorrow}) ==
        ["never", "today", "tomorrow"]
      assert run(date_range: {c.yesterday, c.today}) ==
        ["never", "today", "tomorrow", "yesterday"]
    end
  end
end
