defmodule Eecrit.AnimalReservationReportTxs do
  alias Eecrit.OldAnimalSource
  alias Eecrit.ViewModel

  defp sort_by_first_date(reservations) do
    Enum.sort_by(reservations, fn %{date_range: %{first_date: f}} -> f end)
  end

  def compose(animal_view_model, date_range_view_model, reservation_view_models) do
    %{animal: animal_view_model,
      date_range: date_range_view_model,
      reservations: reservation_view_models}
  end
  
  def run(id, options \\ []) do
    animal = OldAnimalSource.animal_with_reservations(id, options)
    animal_vm = ViewModel.animal(animal)

    date_range_vm = ViewModel.date_range(options[:date_range])
    
    reservation_vms =
      animal.reservations
      |> ViewModel.reservations
      |> sort_by_first_date

    compose(animal_vm, date_range_vm, reservation_vms)
  end
end
