defmodule Eecrit.OldReservationSource do
  import Ecto.Query

  @repo Eecrit.OldRepo

  # Note: joins are a bad idea here because there are duplicate animal
  # and procedure names. Preload, though it takes more queries, doesn't
  # have this issue.
  def base_query do 
    from reservation in Eecrit.OldReservation,
      preload: [:animals, :procedures]
  end

  def restrict_to_date_range(query, first_date_inclusive, last_date_inclusive) do
    first = Ecto.Date.cast!(first_date_inclusive)
    last = Ecto.Date.cast!(last_date_inclusive)
    from [reservation] in query,
      where: fragment("(?, ? + interval '1 day') OVERLAPS (?, ? + interval '1 day')",
        reservation.first_date, reservation.last_date,
        type(^first, :date), type(^last, :date))
  end

  def animal_uses_in_date_range(start_date_inclusive, end_date_inclusive) do
    raw =
      base_query
      |> restrict_to_date_range(start_date_inclusive, end_date_inclusive)
      |> @repo.all

    Enum.map raw, fn reservation ->
      %{animals: reservation.animals,
        procedures: reservation.procedures,
        date_range: {reservation.first_date, reservation.last_date}}
    end
  end
end
