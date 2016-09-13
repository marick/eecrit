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

  def d,
    do: %{
          way_before: "2000-01-09",
          day_before: "2012-01-09",
          reservation_first_date: "2012-01-10",
          first_within: "2012-01-11",
          last_within: "2012-01-19",
          reservation_last_date: "2012-01-20",
          day_after: "2012-01-21"
    }


  describe "fetching reservations that belong to an animal" do
    setup do
      reserved_animal = insert_old_animal(name: "reserved animal")
      other_animal = insert_old_animal(name: "some other animal")
      reserved_procedure = insert_old_procedure(name: "reserved procedure")
      insert_old_procedure(name: "some other procedure")
      reservation_bounds = {d.reservation_first_date, d.reservation_last_date}
      reservation = insert_ranged_reservation!(
        reservation_bounds,
        [reserved_animal], [reserved_procedure])
      provides([reserved_animal, other_animal, reserved_procedure, reservation,
               reservation_bounds])
    end
    
    def assert_same_identities(actual, expected) when is_list(actual),
      do: assert Enum.map(actual, & &1.id) == Enum.map(expected, & &1.id)
    
    def assert_same_identity(actual, expected),
      do: assert actual.id == expected.id
    
    test "returns reservations belonging to the animal", c do
      actual = S.animal_with_reservations(c.reserved_animal.id)
      assert_same_identity(actual, c.reserved_animal)
      [reservation] = actual.reservations  # There should be only one
      assert_same_identity(reservation, c.reservation)

      actual = S.animal_with_reservations(c.other_animal.id)
      assert_same_identity(actual, c.other_animal)
      assert actual.reservations == []
    end

    test "a date range that contains the reservation", c do
      actual = S.animal_with_reservations(c.reserved_animal.id, date_range: c.reservation_bounds)
      assert_same_identity(actual, c.reserved_animal)
      [reservation] = actual.reservations  # There should be only one
      assert_same_identity(reservation, c.reservation)

      actual = S.animal_with_reservations(c.other_animal.id, date_range: c.reservation_bounds)
      assert_same_identity(actual, c.other_animal)
      assert actual.reservations == []
    end

    test "... and one that does not", c do
      no_overlap = {d.way_before, d.day_before}
      actual = S.animal_with_reservations(c.reserved_animal.id, date_range: no_overlap)
      assert_same_identity(actual, c.reserved_animal)
      assert actual.reservations == []
    end
    test "it's typical to look at procedures, so they are preloaded", c do 
      %{reservations: [%{procedures: procs}]} =
        S.animal_with_reservations(c.reserved_animal.id)
      assert_same_identities(procs, [c.reserved_procedure])
    end
  end

end
