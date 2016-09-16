defmodule Eecrit.AnimalReservationsViewTest do
  use Eecrit.ViewCase, async: true
  alias Eecrit.ReportView
  alias Eecrit.ViewModel, as: VM

  setup c do
    a1 = make_old_animal(id: 11, name: "this-is-animal-1")
    a1v = VM.animal(a1)
    p1 = make_old_procedure(id: 111, name: "this-is-procedure-1")
    query_date_range = VM.date_range({"2016-05-16", "2016-06-15"})
    reservation =
      make_old_reservation_fields
      |> Map.put(:procedures, [p1])
      |> VM.reservation
    
    view_model = Eecrit.AnimalReservationReportTxs.compose(a1v, query_date_range, [reservation])

    html = render_to_string(ReportView, "animal_reservations.html",
      conn: c.conn, view_model: view_model)

    provides([a1, p1, query_date_range, html])
  end

  test "key text appears", c do
    c.html
    |> matches!(c.a1.name)
    |> matches!(c.p1.name)
    |> matches!(Eecrit.ModelDisplays.date(c.query_date_range.first_date))
    |> matches!(Eecrit.ModelDisplays.date(c.query_date_range.last_date))
  end

  test "outgoing links", c do
    c.html
    |> allows_show!(c.a1, text: c.a1.name)
    |> allows_show!(c.p1, text: c.p1.name)
  end    
end
