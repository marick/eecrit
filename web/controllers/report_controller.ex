defmodule Eecrit.ReportController do
  use Eecrit.Web, :controller
  alias Eecrit.AnimalUseReportTxs
  alias Eecrit.AnimalReservationReportTxs
  alias Eecrit.ViewModel

  def animal_use(conn, %{"report" => params}) do
    %{"first_date" => first_date, "last_date" => last_date} = params
    view_model = AnimalUseReportTxs.run({first_date, last_date})
    date_range = ViewModel.date_range({first_date, last_date})
    render(conn, "animal_use.html", view_model: view_model, input_data: date_range)
  end

  def animal_use(conn, _params) do
    render(conn, "animal_use_new.html")
  end

  def animal_reservations(conn,
    %{"animal" => id, "first_date" => first_date,  "last_date" => last_date}) do
    view_model = AnimalReservationReportTxs.run(id,
      date_range: {first_date, last_date})
    render(conn, "animal_reservations.html", view_model: view_model)
  end
end
