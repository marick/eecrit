defmodule Eecrit.TimeUtil do
  use Timex

  def ecto_date_to_date(ecto_date) do
    ecto_date
    |> Ecto.Date.to_erl()
    |> Date.from_erl!()
  end

  def format_ecto_date(nil), do: ""
  def format_ecto_date(ecto_date) do 
    ecto_date
    |> ecto_date_to_date
    |> Timex.format!("%B %-d, %Y", :strftime)
  end
end
