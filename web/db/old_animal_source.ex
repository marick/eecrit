defmodule Eecrit.OldAnimalSource do
  import Ecto.Query
  alias Eecrit.OldAnimal

  @repo Eecrit.OldRepo

  def all_ordered(options \\ []) do
    base = from a in OldAnimal, order_by: fragment("lower(?)", a.name)
    tailored = add_tailoring(base, options)
    @repo.all(tailored)
  end

  defp add_tailoring(base_query, options) do 
    Enum.reduce(options, base_query, fn(option, query_so_far) ->
      tailor(query_so_far, option)
    end)
  end
  
  defp tailor(query, {:include_out_of_service, false}) do
    query
    |> where([a], is_nil(a.date_removed_from_service) or a.date_removed_from_service > fragment("CURRENT_DATE"))
  end

  defp tailor(query, _), do: query
end
