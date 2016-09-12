defmodule Eecrit.AnimalUseReportTxs do
  @moduledoc """
  Flow:
  [... {animal_id, procedure_id, count} ... ]        
  [... [animal_id, {procedure_id, count},  {procedure_id, count}...] ...     
  [... [animal, {procedure, count}, {procedure, count}...] ...       
  [... [animal-view, procedure-view, procedure-view...] ...]       
  (then sorted version of above)

  Most of the work is done on data with a list-of-lists structure, where
  the head of a sublist is about an animal and the tail is about procedures.
  """
  
  alias Eecrit.Pile
  alias Eecrit.OldAnimalSource
  alias Eecrit.OldUseSource
  alias Eecrit.OldProcedureSource

  defmodule P do
    defp two_level_transform(list_of_lists, hd_transform, tail_transform) do
      for [a | p_list] <- list_of_lists,
        do: [ hd_transform.(a) | Enum.map(p_list, tail_transform) ]
    end

    @doc """
    [... {animal_id, procedure_id, count} ... ]   # becomes:      
    [... [animal_id, {procedure_id, count},  {procedure_id, count}...] ...
    """
    def create_list_of_lists(uses, ids_of_all_available_animals) do
      starting_map = Map.new(ids_of_all_available_animals, & {&1, []})
      
      add_to_intermediate_map = fn({animal_id, procedure_id, count}, intermediate) ->
        current = Map.get(intermediate, animal_id)
        %{intermediate | animal_id => [{procedure_id, count} | current]}
      end

      final_map = Enum.reduce(uses, starting_map, add_to_intermediate_map)
      Enum.map(final_map, fn {animal_id, list} -> [animal_id | list] end)
    end

    @doc """
    [... [animal_id, {procedure_id, count},  {procedure_id, count}...] ...  
    [... [animal, {procedure, count}, {procedure, count}...] ...       
    """
    def convert_ids_to_models(list_of_lists, animals, procedures) do
      procedures_by_id = Pile.index(procedures, :id)
      animals_by_id = Pile.index(animals, :id)

      modelize_animal = fn animal_id -> Map.get(animals_by_id, animal_id) end
      modelize_procedure = fn {p_id, count} ->
        { Map.get(procedures_by_id, p_id), count }
      end
      two_level_transform(list_of_lists, modelize_animal, modelize_procedure)
    end

    @doc """
    [... [animal, {procedure, count}, {procedure, count}...] ...       
    [... [animal-view, procedure-view, procedure-view...] ...]       
    """
    def convert_models_to_model_views(list_of_lists) do
      procedure_view = fn {procedure, count} ->
        procedure
        |> Map.take([:name, :id])
        |> Map.put(:use_count, count)
      end
      
      animal_view = fn animal -> Map.take(animal, [:name, :id]) end
      two_level_transform(list_of_lists, animal_view, procedure_view)
    end

    def two_level_sort(list_of_lists) do
      list_of_lists
      |> Enum.map(fn [a | plist] -> [a | Pile.sort_by_name_key(plist)] end)
      |> Pile.sort_human_alphabetically(fn list -> hd(list).name end)
    end

    def sum_counts_of_duplicate_animal_procedure_pairs(uses) do
      grouped_counts = Enum.group_by(
        uses,
        fn {animal_id, procedure_id, _} -> {animal_id, procedure_id} end,
        fn {_, _, use_count} -> use_count end)
      
      for { {animal_id, procedure_id}, counts} <- grouped_counts do
        {animal_id, procedure_id, Enum.sum(counts)}
      end
    end

    def view_model(uses, animals, procedures) do
      animal_ids = Enum.map(animals, & &1.id)
      uses
      |> sum_counts_of_duplicate_animal_procedure_pairs
      |> create_list_of_lists(animal_ids)
      |> convert_ids_to_models(animals, procedures)
      |> convert_models_to_model_views
      |> two_level_sort
    end

    def procedures_from_use_tuples(uses) do
      ids = (for {_, p_id, _} <- uses, do: p_id) |> Enum.uniq
      OldProcedureSource.all(with_ids: ids)
    end

    def gratuitous_parallelism(date_range),
      do: Task.async(fn -> OldAnimalSource.all(ever_in_service_during: date_range) end)
  end

  ### PUBLIC
  
  def run(date_range) do
    animals_task = P.gratuitous_parallelism(date_range)
    uses = OldUseSource.use_counts(date_range)
    procedures = P.procedures_from_use_tuples(uses)

    uses |> P.view_model(Task.await(animals_task), procedures)
  end
end
