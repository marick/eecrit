defmodule Eecrit.OldReservationSource do
  import Ecto.Query
  @repo Eecrit.OldRepo

  def base_query do 
    from reservation in Eecrit.OldReservation,
      where: reservation.id in [10, 13, 17, 18, 20],
      join: animal in assoc(reservation, :animals),
      join: procedure in assoc(reservation, :procedures)
  end

  def restrict_to_date_range(query, start_date_inclusive, end_date_inclusive) do
    from [reservation] in query,
      where: fragment("(?, ? + interval '1 day') OVERLAPS (?, ? + interval '1 day')",
        reservation.first_date, reservation.last_date,
        type(^start_date_inclusive, :date),
        type(^end_date_inclusive, :date))
  end

  def select_animal_procedure_period(query) do
    from [reservation, animal, procedure] in query,
      select: {animal.name, procedure.name, reservation.first_date, reservation.last_date}
  end
    

  def procedures_per_animal(start_date_inclusive, end_date_inclusive) do
    base_query
    |> restrict_to_date_range(start_date_inclusive, end_date_inclusive)
    |> select_animal_procedure_period
    |> Eecrit.OldRepo.all
#    |> Enum.map(&(trim_dates(&1, {start_date_include
#    |> Enum.map(add_day_count)
  end
end
