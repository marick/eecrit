defmodule Eecrit.ReportController do
  use Eecrit.Web, :controller
  alias Eecrit.AnimalUseReportTxs

  # localhost:4000/reports/animal-use?first_date=2015-01-01&last_date=2015-06-01
  def animal_use(conn, %{"first_date" => first_date, "last_date" => last_date}) do
    view_model = AnimalUseReportTxs.run({first_date, last_date})
    render(conn, "animal_use.html", view_model: view_model)
  end

  def animal_use(conn, params) do
    render(conn, "animal_use.html")
  end
end
