defmodule Eecrit.AnimalReservationReportTxs do
  alias Eecrit.OldAnimalSource
  alias Eecrit.ViewModel

  defp sort_by_first_date(reservations) do
    Enum.sort_by(reservations, fn %{date_range: {sortable, _}} -> sortable end)
  end
  
  
  def run(id, options \\ []) do
    animal = OldAnimalSource.animal_with_reservations(id, options)
    reservations = animal.reservations |> ViewModel.reservation |> sort_by_first_date

    %{animal: ViewModel.animal(animal),
      date_range: options[:date_range] || :infinity,
      reservations: reservations}
  end
end
