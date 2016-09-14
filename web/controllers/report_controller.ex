defmodule Eecrit.ReportController do
  use Eecrit.Web, :controller
  alias Eecrit.AnimalUseReportTxs
  alias Eecrit.AnimalReservationReportTxs

  def animal_use(conn, %{"report" => params}) do
     %{"first_date" => first_date, "last_date" => last_date} = params
     view_model = AnimalUseReportTxs.run({first_date, last_date})
     render(conn, "animal_use.html", view_model: view_model)
  end

  def animal_use(conn, _params) do
    render(conn, "animal_use_new.html")
  end

  def animal_reservations(conn, params) do
    view_model = AnimalReservationReportTxs.run(216,
      date_range: {"2015-12-11", "2016-12-01"})
    render(conn, "animal_reservations.html", view_model: view_model)
  end
end
