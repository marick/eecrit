defmodule Eecrit.OldReservationSource do
  import Ecto.Query
  alias Eecrit.TimeUtil

  @repo Eecrit.OldRepo

  ### Some of these functions are public for testing.

  # Note: joins are a bad idea here because there are duplicate animal
  # and procedure names. Preload, though it takes more queries, doesn't
  # have this issue.
  def base_query do 
    from reservation in Eecrit.OldReservation,
      preload: [:animals, :procedures]
  end

  def restrict_to_date_range(query, {first_date_inclusive, last_date_inclusive}) do
    first = Ecto.Date.cast!(first_date_inclusive)
    last = Ecto.Date.cast!(last_date_inclusive)
    from [reservation] in query,
      where: fragment("(?, ? + interval '1 day') OVERLAPS (?, ? + interval '1 day')",
        reservation.first_date, reservation.last_date,
        type(^first, :date), type(^last, :date))
  end


  ### These are the public functions

  def animal_use_days(bounds = {%Ecto.Date{}, %Ecto.Date{}}) do
    # The query can return values that overlap the bounds.
    trim_range = fn reservation ->
      TimeUtil.adjust_range_in_struct(reservation,
        {:first_date, :last_date},
        within: bounds)
    end

    condense_result = fn reservation ->
      %{animals: reservation.animals,
        procedures: reservation.procedures,
        date_range: {reservation.first_date, reservation.last_date}
       }
    end

    base_query
    |> restrict_to_date_range(bounds)
    |> @repo.all
    |> Enum.map(trim_range)
    |> Enum.map(condense_result)
  end

  def animal_use_days({first, last}),
    do: animal_use_days({Ecto.Date.cast!(first), Ecto.Date.cast!(last)})
end
