defmodule Eecrit.OldUseSourceTest do
  use Eecrit.ModelCase
  alias Eecrit.OldUseSource, as: S
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
          reservation_last_date: "2012-01-20",  # 11 days long reservation (inclusive)
          day_after: "2012-01-21"
    }

  def insert_ranged_reservation!(animals \\ [], procedures \\ []) do 
    r = make_old_reservation_fields(
      first_date: d.reservation_first_date,
      last_date: d.reservation_last_date)
    OldReservationSink.make_full!(r, animals, procedures)
  end

  describe "use_counts" do
    setup do
      a1 = insert_old_animal(name: "a1")
      a2 = insert_old_animal(name: "a2")
      p1 = insert_old_procedure(name: "p1")
      p2 = insert_old_procedure(name: "p2")

      insert_ranged_reservation!([a1, a2], [p1, p2])
      provides([a1, a2, p1, p2])
    end

    def assert_four_animals(result, c, expected_count) do
      assert {c.a1.id, c.p1.id, expected_count} in result
      assert {c.a1.id, c.p2.id, expected_count} in result
      assert {c.a2.id, c.p1.id, expected_count} in result
      assert {c.a2.id, c.p2.id, expected_count} in result
    end

    test "reservation outside of boundary" do
      [] = S.use_counts({d.way_before, d.day_before})
    end

    test "reservation is well within the bounds", c do
      result = S.use_counts({d.day_before, d.day_after})
      assert_four_animals(result, c, 11)
    end

    test "reservation is exactly within the bounds", c do
      result = S.use_counts({d.reservation_first_date, d.reservation_last_date})
      assert_four_animals(result, c, 11)
    end

    test "reservation overlaps the bounds", c do
      result = S.use_counts({d.first_within, d.last_within})
      assert_four_animals(result, c, 9)
    end
  end
end
