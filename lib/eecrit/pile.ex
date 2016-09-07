defmodule Eecrit.Pile do

  def extract_values(list, key) do
    Enum.map(list, &(Map.get(&1, key)))
  end

  def sort_human_alphabetically(structs, f) when is_function(f) do
    Enum.sort(structs, fn(a, b) ->
      extract = fn x -> x |> f.() |> String.downcase end
      extract.(a) < extract.(b)
    end)
  end

  def sort_human_alphabetically(structs, key),
    do: sort_human_alphabetically(structs, &(Map.get(&1, key)))

  def sort_by_name_key(structs) do
    sort_human_alphabetically(structs, :name)
  end

  # TODO: Port Clojure version
  def index(maps, index_key), do: Map.new(maps, &({Map.get(&1, index_key), &1}))
end
