defmodule Eecrit.ViewModel do
  def animal(model), do: Map.take(model, [:name, :id])

  def procedure(list) when is_list(list), do: Enum.map(list, &procedure/1)
  def procedure(%Eecrit.OldProcedure{} = model), do: Map.take(model, [:name, :id])
  def procedure(%Ecto.Association.NotLoaded{}), do: []

  def reservation(list) when is_list(list), do: Enum.map(list, &reservation/1)
  def reservation(%Eecrit.OldReservation{} = model) do
    model 
    |> Map.take([:course, :instructor, :time_bits])
    |> Map.put(:date_range, date_range({Ecto.Date.to_iso8601(model.first_date),
                                       Ecto.Date.to_iso8601(model.last_date)}))
    |> Map.put(:procedures, procedure(model.procedures))
  end

  def date_range(%{first_date: first, last_date: last} = range), do: range
  def date_range({first, last}), do: %{first_date: first, last_date: last}
  def date_range(:infinity), do: :infinity
  def date_range(nil), do: :infinity
  
end
