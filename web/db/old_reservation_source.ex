defmodule Eecrit.OldReservationSource do
  import Ecto.Query
  alias Eecrit.OldReservation

  @repo Eecrit.OldRepo

  defmodule P do 
    def tailor(query, {:date_range, bounds}) do
      {first_date_inclusive, last_date_inclusive} = bounds
      first = Ecto.Date.cast!(first_date_inclusive)
      last = Ecto.Date.cast!(last_date_inclusive)
      from [reservation] in query,
        where: fragment("(?, ? + interval '1 day') OVERLAPS (?, ? + interval '1 day')",
          reservation.first_date, reservation.last_date,
          type(^first, :date), type(^last, :date))
    end
  end

  def tailor(base_query, options) when is_list(options) do 
    Enum.reduce(options, base_query, fn(option, query_so_far) ->
      P.tailor(query_so_far, option)
    end)
  end
end
