defmodule Eecrit.ReportController do
  use Eecrit.Web, :controller
  alias Eecrit.OldAnimal

  @animal_use_query """
  SELECT animals.name, procedures.name, reservations.first_date, reservations.last_date, reservations.id FROM animals
  JOIN uses ON uses.animal_id = animals.id
  JOIN procedures ON procedures.id = uses.procedure_id
  JOIN groups ON groups.id = uses.group_id
  JOIN reservations ON reservations.id = groups.reservation_id
  """

  
  
  def animal_use(conn, _params) do
    res = Ecto.Adapters.SQL.query!(Eecrit.OldRepo, @animal_use_query, [])

    Enum.map(res.rows, fn(row) ->
      if Enum.at(row, 2) != Enum.at(row, 3) do 
        IO.puts "#{Enum.at(row, 0)} was used from #{inspect Enum.at(row, 2)} to #{inspect Enum.at(row, 3)}"
      end
    end)

    render(conn, "animal_use.html")
  end
end
