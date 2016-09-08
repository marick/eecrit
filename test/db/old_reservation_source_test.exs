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
  
  describe "handling of date ranges" do
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
      |> S.restrict_to_date_range({query_first, query_last})
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
end
