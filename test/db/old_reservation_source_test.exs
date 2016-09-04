defmodule Eecrit.OldReservationSourceTest do
  use Eecrit.ModelCase
  alias Eecrit.OldReservationSource, as: S
  alias Eecrit.OldReservation
  alias Eecrit.OldReservationSink
  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure

  @repo Eecrit.OldRepo

  test "base query" do
    animals = [insert_old_animal(name: "a1"), insert_old_animal(name: "a2")]
    procedures = [insert_old_procedure(name: "p1"), insert_old_procedure(name: "p2")]

    make_old_reservation_fields
    |> OldReservationSink.make_full!(animals, procedures)

    reservation = @repo.one(S.base_query)
    assert OldAnimal.alphabetical_names(reservation.animals) == ["a1", "a2"]
    assert OldProcedure.alphabetical_names(reservation.procedures) == ["p1", "p2"]
  end
  
  @way_before "2000-01-09"
  @day_before "2012-01-09"
  @reservation_first_date "2012-01-10"
  @first_within "2012-01-11"
  @last_within "2012-01-19"
  @reservation_last_date "2012-01-20"
  @day_after "2012-01-21"

  
  describe "handling of date ranges" do
    def reservations_within(query_first, query_last) do
      make_old_reservation_fields(first_date: @reservation_first_date,
                                  last_date: @reservation_last_date)
      |> OldReservationSink.make_full!([], [])

      @repo.one(S.base_query |> S.restrict_to_date_range({query_first, query_last}))
    end

    def assert_found(actual) do
      assert actual
      assert actual.first_date == Ecto.Date.cast!(@reservation_first_date)
      assert actual.last_date == Ecto.Date.cast!(@reservation_last_date)
    end

    test "reservation lies entirely outside query period" do
      assert reservations_within(@way_before, @day_before) == nil
    end

    test "reservation lies entirely inside query period" do
      assert_found reservations_within(@first_within, @last_within)
    end

    test "the start is inclusive (and overlaps are allowed)" do
      assert_found reservations_within(@reservation_last_date, @day_after)
    end

    test "the end is inclusive" do
      assert_found reservations_within(@day_before, @reservation_first_date)
    end
  end

  describe "animal_use_days" do
    setup do
      animals = [insert_old_animal(name: "a1"), insert_old_animal(name: "a2")]
      procedures = [insert_old_procedure(name: "p1"), insert_old_procedure(name: "p2")]

      make_old_reservation_fields(first_date: @reservation_first_date, last_date: @reservation_last_date)
      |> OldReservationSink.make_full!(animals, procedures)
      :ok
    end

    test "reservation fits nicely within date boundaries" do
      [reservation] = S.animal_use_days({@day_before, @day_after})
      assert OldAnimal.alphabetical_names(reservation.animals) == ["a1", "a2"]
      assert OldProcedure.alphabetical_names(reservation.procedures) == ["p1", "p2"]
      assert reservation.date_range ==
        {Ecto.Date.cast!(@reservation_first_date), Ecto.Date.cast!(@reservation_last_date)}
    end

    test "date ranges can be truncated" do
      [reservation] = S.animal_use_days({@first_within, @last_within})
      assert OldAnimal.alphabetical_names(reservation.animals) == ["a1", "a2"]
      assert OldProcedure.alphabetical_names(reservation.procedures) == ["p1", "p2"]
      assert reservation.date_range ==
        {Ecto.Date.cast!(@first_within), Ecto.Date.cast!(@last_within)}
    end
  end
end
