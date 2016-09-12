defmodule Eecrit.ModelDisplays do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers
  alias Eecrit.TimeUtil
  require Timex

  def animal(conn, view_model) do 
    link view_model.name,
      to: old_animal_path(conn, :show, view_model.id),
      title: "Show details for this animal"
  end

  def procedure(conn, view_model) do 
    link view_model.name,
      to: old_procedure_path(conn, :show, view_model.id),
      title: "Show details for this procedure"
  end

  def date(nil), do: ""
  def date(d),
    do: d |> TimeUtil.cast_to_date! |> Timex.format!("%B %-d, %Y", :strftime)
  
  def date_range(%{first_date: first_date, last_date: last_date}),
    do: date_range({first_date, last_date})
  def date_range({first_date, last_date}) do 
    {first_view, last_view} = {date(first_date), date(last_date)}
    if first_view == last_view do
      "on #{first_view}"
    else
      "from #{first_view} through #{last_view}"
    end
  end
end
