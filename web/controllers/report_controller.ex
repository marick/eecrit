defmodule Eecrit.ReportController do
  use Eecrit.Web, :controller
  alias Eecrit.OldProcedure
  alias Eecrit.OldAnimal
  alias Eecrit.Pile
  alias Eecrit.OldAnimalSource
  alias Eecrit.OldUseSource
  alias Eecrit.OldProcedureSource

  def view_model(animals, procedures, uses) do
    all_empty = Map.new(animals, & {&1.id, []})
    procedures_by_id = Pile.index(procedures, :id)
    animals_by_id = Pile.index(animals, :id)

    procedure_view = fn id, count ->
      Map.get(procedures_by_id, id)
      |> Map.take([:name, :id])
      |> Map.put(:use_count, count)
    end

    animal_view = fn id ->
      Map.get(animals_by_id, id)
      |> Map.take([:name, :id])
    end

    unsorted_procedures = 
      Enum.reduce(uses, all_empty, fn({animal_id, procedure_id, count}, acc) ->
        current = Map.get(acc, animal_id)
        %{acc | animal_id => [procedure_view.(procedure_id, count) | current]}
      end)

    unsorted_animals = 
      Enum.map(unsorted_procedures, fn {animal_id, procedure_list} ->
        [animal_view.(animal_id) | Pile.sort_by_name_key(procedure_list)]
      end)

    Pile.sort_human_alphabetically(unsorted_animals, &(hd(&1)).name)
  end

  def aggregate_use_counts(uses) do
    grouped_counts = Enum.group_by(
      uses,
      fn {animal_id, procedure_id, _} -> {animal_id, procedure_id} end,
      fn {_, _, use_count} -> use_count end)

    for { {animal_id, procedure_id}, counts} <- grouped_counts do
      {animal_id, procedure_id, Enum.sum(counts)}
    end
  end

  def end_to_end(date_range) do
    animals = OldAnimalSource.all_ordered(date_range: date_range)
    uses = OldUseSource.use_counts(date_range) |> aggregate_use_counts
    used_procedure_ids = for {_, p_id, _} <- uses, do: p_id
    procedures = OldProcedureSource.all_ordered(with_ids: used_procedure_ids)

    view_model(animals, procedures, uses)
  end

  # localhost:4000/reports/animal-use?first_date=2015-01-01&last_date=2015-06-01
  def animal_use(conn, %{"first_date" => first_date, "last_date" => last_date}) do
    render(conn, "animal_use.html", data: end_to_end({first_date, last_date}))
  end

  def animal_use(conn, params) do
    render(conn, "animal_use.html")
  end


end
