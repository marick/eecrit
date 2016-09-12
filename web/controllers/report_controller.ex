defmodule Eecrit.ReportController do
  use Eecrit.Web, :controller
  alias Eecrit.AnimalUseReportTxs

  def animal_use(conn, %{"report" => params}) do
     %{"first_date" => first_date, "last_date" => last_date} = params
     view_model = AnimalUseReportTxs.run({first_date, last_date})
     render(conn, "animal_use.html", view_model: view_model)
  end

  def animal_use(conn, _params) do
    render(conn, "animal_use_new.html")
  end

  def animal_reservations(conn, _params) do
    animal = %{id: 11, name: "a1"}
    date_range = %{first_date: "2015-12-11", last_date: "2016-12-01"}
    reservation = %{date_range: {"2016-03-11", "2016-03-11"},
                    times_of_day: "011",
                    course: "vcm333",
                    instructor: "Dr. Foozle",
                    procedures: [%{id: 111, name: "p1"}, %{id: 222, name: "p2"}]}
    view_model = %{animal: animal,
                   date_range: date_range,
                   reservations: [reservation]}
    render(conn, "animal_reservations.html", view_model: view_model)
  end
end
