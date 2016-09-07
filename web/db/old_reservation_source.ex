defmodule Eecrit.OldReservationSource do
  import Ecto.Query
  alias Eecrit.TimeUtil

  @repo Eecrit.OldRepo

  def restrict_to_date_range(query, {first_date_inclusive, last_date_inclusive}) do
    first = Ecto.Date.cast!(first_date_inclusive)
    last = Ecto.Date.cast!(last_date_inclusive)
    from [reservation] in query,
      where: fragment("(?, ? + interval '1 day') OVERLAPS (?, ? + interval '1 day')",
        reservation.first_date, reservation.last_date,
        type(^first, :date), type(^last, :date))
  end
end
