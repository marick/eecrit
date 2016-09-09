defmodule Eecrit.AnimalUseReportTxs do 
  alias Eecrit.Pile
  alias Eecrit.OldAnimalSource
  alias Eecrit.OldUseSource
  alias Eecrit.OldProcedureSource

  defmodule P do
    def view_model(uses, animals, procedures) do
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

    def gratuitous_parallelism(date_range, uses) do
      animal_task = Task.async(fn ->
        OldAnimalSource.all_ordered(date_range: date_range)
      end)

      procedure_task = Task.async(fn -> 
        used_procedure_ids = (for {_, p_id, _} <- uses, do: p_id) |> Enum.uniq
        OldProcedureSource.all_ordered(with_ids: used_procedure_ids)
      end)

      {animal_task, procedure_task}
    end
      
    def relevant_animals({animal_task, _}), do: Task.await(animal_task)
    def relevant_procedures({_, procedure_task}), do: Task.await(procedure_task)
  end

  ### PUBLIC
  
  def run(date_range) do
    uses = OldUseSource.use_counts(date_range) |> P.aggregate_use_counts
    token = P.gratuitous_parallelism(date_range, uses)
    P.view_model(uses, P.relevant_animals(token), P.relevant_procedures(token))
  end
end
