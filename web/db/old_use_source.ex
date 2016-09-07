defmodule Eecrit.OldUseSource do
  import Ecto.Query
  alias Eecrit.TimeUtil
  alias Eecrit.OldReservationSource

  @repo Eecrit.OldRepo


  ### These are the public functions

  def use_counts(bounds = {%Ecto.Date{}, %Ecto.Date{}}) do
    # The query can return values that overlap the bounds.
    trim_range = fn reservation ->
      TimeUtil.adjust_range_in_struct(reservation,
        {:first_date, :last_date},
        within: bounds)
    end

    condense_result = fn reservation ->
      days_covered = 
        {reservation.first_date, reservation.last_date}
        |> TimeUtil.days_covered
      
      Enum.map(reservation.uses, fn u ->
        {u.animal_id, u.procedure_id, days_covered}
      end)
    end

    base_query = from reservation in Eecrit.OldReservation, preload: [:uses]

    base_query
    |> OldReservationSource.restrict_to_date_range(bounds)
    |> @repo.all
    |> Enum.map(trim_range)
    |> Enum.flat_map(condense_result)
  end

  def use_counts({first, last}),
    do: use_counts({Ecto.Date.cast!(first), Ecto.Date.cast!(last)})
end
