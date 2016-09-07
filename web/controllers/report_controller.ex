defmodule Eecrit.ReportController do
  use Eecrit.Web, :controller
  alias Eecrit.OldProcedure
  alias Eecrit.OldAnimal
  alias Eecrit.Pile

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

  
  def animal_use(conn, _params) do
    animals = [%OldAnimal{id: 11, name: "a1"},
               %OldAnimal{id: 33, name: "a3"},
               %OldAnimal{id: 22, name: "a2"},
              ]

    procedures = [%OldProcedure{id: 111, name: "p1"},
                  %OldProcedure{id: 333, name: "p3"},
                  %OldProcedure{id: 222, name: "p2"},
                 ]

    uses = [{11, 111, 1},
            {11, 222, 2},
            {22, 111, 3},
            {22, 333, 4},
           ]

    
    data = view_model(animals, procedures, uses)
    render(conn, "animal_use.html", data: data)
   end
end
