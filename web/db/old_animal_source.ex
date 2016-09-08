defmodule Eecrit.OldAnimalSource do
  import Ecto.Query
  alias Eecrit.OldAnimal

  @repo Eecrit.OldRepo

  defmodule P do 
    def tailor(base_query, options) when is_list(options) do 
      Enum.reduce(options, base_query, fn(option, query_so_far) ->
        tailor(query_so_far, option)
      end)
    end
    
    def tailor(query, {:include_out_of_service, true}), do: query
    def tailor(query, {:include_out_of_service, false}) do
      query
      |> where([a],
         is_nil(a.date_removed_from_service) or
         a.date_removed_from_service > fragment("CURRENT_DATE"))
    end

    def tailor(query, {:date_range, {first_date, _}}) do
      query
      |> where([a],
         is_nil(a.date_removed_from_service) or
         a.date_removed_from_service >= ^Ecto.Date.cast!(first_date))
    end
  end

  ## PUBLIC

  def all_ordered(options \\ []) do
    query = from a in OldAnimal, order_by: fragment("lower(?)", a.name)

    query
    |> P.tailor(options)
    |> @repo.all
  end
end
