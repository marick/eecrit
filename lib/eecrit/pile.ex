defmodule Eecrit.Pile do

  def fields(list, key) do
    Enum.map(list, &(Map.get(&1, key)))
  end

  def sort_human_alphabetically(structs, key) do
    Enum.sort(structs, fn(a, b) ->
      extract = fn x -> x |> Map.get(key) |> String.downcase end
      extract.(a) < extract.(b)
    end)
  end
end
