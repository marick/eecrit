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


  defp base_date_range(%{first_date: first_date, last_date: last_date}),
    do: base_date_range({first_date, last_date})
  defp base_date_range({first_date, last_date}) do 
    {first_view, last_view} = {date(first_date), date(last_date)}
    if first_view == last_view do
      ["on", first_view]
    else
      ["from", "#{first_view} through #{last_view}"]
    end
  end
  
  def date_range(range),
    do: range |> base_date_range |> Enum.join(" ")
  def date_range_without_prefix(range),
    do: range |> base_date_range |> Enum.at(1)

  # Whee! Pattern matching!
  def times("000"), do: "never"
  def times("001"), do: "evening"
  def times("010"), do: "afternoon"
  def times("100"), do: "morning"
  def times("011"), do: "afternoon and evening"
  def times("101"), do: "morning and evening"
  def times("110"), do: "morning and afternoon"
  def times("111"), do: "morning, afternoon, and evening"
end
