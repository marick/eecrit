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
end
