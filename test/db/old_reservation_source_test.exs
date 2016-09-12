defmodule Eecrit.OldReservationSourceTest do
  use Eecrit.ModelCase
  alias Eecrit.OldReservationSource, as: S
  alias Eecrit.OldReservation
  alias Eecrit.OldReservationSink

  @repo Eecrit.OldRepo

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

  def insert_ranged_reservation!(animals \\ [], procedures \\ []) do 
    r = make_old_reservation_fields(
      first_date: d.reservation_first_date,
      last_date: d.reservation_last_date)
    OldReservationSink.make_full!(r, animals, procedures)
  end
  
  describe "tailoring of date ranges for query" do
    setup do
      insert_ranged_reservation!
      :ok
    end

    def assert_found(reservation) do
      assert reservation
      assert reservation.first_date == Ecto.Date.cast!(d.reservation_first_date)
      assert reservation.last_date == Ecto.Date.cast!(d.reservation_last_date)
    end

    def reservations_within({query_first, query_last}) do
      (from r in OldReservation)
      |> S.tailor(date_range: {query_first, query_last})
      |> @repo.one
    end
    
    test "reservation lies entirely outside query period" do
      assert reservations_within({d.way_before, d.day_before}) == nil
    end

    test "reservation lies entirely inside query period" do
      assert_found reservations_within({d.first_within, d.last_within})
    end

    test "the start is inclusive (and overlaps are allowed)" do
      assert_found reservations_within({d.reservation_last_date, d.day_after})
    end

    test "the end is inclusive" do
      assert_found reservations_within({d.day_before, d.reservation_first_date})
    end
  end


  describe "fetching reservations that belong to an animal" do
    setup do
      reserved_animal = insert_old_animal(name: "reserved animal")
      other_animal = insert_old_animal(name: "some other animal")
      reserved_procedure = insert_old_procedure(name: "reserved procedure")
      insert_old_procedure(name: "some other procedure")
      reservation = insert_ranged_reservation!([reserved_animal], [reserved_procedure])
      provides([reserved_animal, other_animal, reserved_procedure, reservation])
    end
    
    def assert_same_identity(actual, expected),
      do: assert Enum.map(actual, & &1.id) == Enum.map(expected, & &1.id)
    
    test "returns reservations belonging to the animal", c do
      [actual] = S.reservations_for_animal(c.reserved_animal.id)
      assert_same_identity([actual], [c.reservation])

      [] = S.reservations_for_animal(c.other_animal.id)
    end

    test "it's typical to preload procedures", c do 
      [actual] = S.reservations_for_animal(c.reserved_animal.id, preload: :procedures)
      assert_same_identity(actual.procedures, [c.reserved_procedure])
    end

    test "you can also give a date range", c do
      [actual] = S.reservations_for_animal(c.reserved_animal.id,
        date_range: {d.day_before, d.day_after},
        preload: :procedures)
      assert_same_identity(actual.procedures, [c.reserved_procedure])

      [] = S.reservations_for_animal(c.reserved_animal.id,
        date_range: {d.way_before, d.day_before},
        preload: :procedures)

      # Note that, as usual, any overlap in dates suffices to include.
      [actual] = S.reservations_for_animal(c.reserved_animal.id,
        date_range: {d.way_before, d.first_within},
        preload: :procedures)
      assert_same_identity(actual.procedures, [c.reserved_procedure])
    end
  end
end
