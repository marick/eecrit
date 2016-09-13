defmodule Eecrit.AnimalReservationReportTxsTest do
  use Eecrit.ConnCase
  alias Eecrit.AnimalReservationReportTxs, as: S
  alias Eecrit.ViewModel

  test "end to end" do
    reservation_month = {"2016-06-01", "2016-06-30"}
    far_future = {"2026-06-01", "2026-06-30"}
    distant_past = {"2006-06-01", "2006-06-01"}
    query_period = {"2016-05-16", "2016-06-15"}  # Note overlap
    
    a1 = insert_old_animal(name: "a1")
    a2 = insert_old_animal(name: "a2")

    p1 = insert_old_procedure(name: "p1")
    p2 = insert_old_procedure(name: "p2")

    actual = S.run(a1.id, date_range: query_period)
    assert (actual.animal) == ViewModel.animal(a1)
    assert actual.date_range == query_period
    assert actual.reservations == []

    reservation = insert_ranged_reservation!(reservation_month, [a1, a2], [p1, p2])

    actual = S.run(a1.id, date_range: query_period)
    assert (actual.animal) == ViewModel.animal(a1)
    assert actual.date_range == query_period
    [actual_reservation] = actual.reservations
    assert actual_reservation.course == reservation.course
    assert actual_reservation.instructor == reservation.instructor
    assert actual_reservation.time_bits == reservation.time_bits
    assert actual_reservation.date_range == reservation_month

    assert_same_elements(
      actual_reservation.procedures,
      [ViewModel.procedure(p1), ViewModel.procedure(p2)])

    ## Out-of-query-period elements are not returned

    insert_ranged_reservation!(far_future, [a1], [p2])
    insert_ranged_reservation!(distant_past, [a1], [p1])
    actual = S.run(a1.id, date_range: query_period)
    assert (actual.animal) == ViewModel.animal(a1)
    # Still only one reservation
    [_actual_reservation] = actual.reservations

    # Can also ask without a date range, which returns everything
    actual = S.run(a1.id)
    assert (actual.animal) == ViewModel.animal(a1)
    assert actual.date_range == :infinity
    [past, current, future] = actual.reservations
    # Note ordering is by first reservation date
    assert past.date_range == distant_past
    assert current.date_range == reservation_month
    assert future.date_range == far_future
  end

end
