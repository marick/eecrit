defmodule Eecrit.OldProcedureSource do
  import Ecto.Query
  alias Eecrit.OldProcedure

  @repo Eecrit.OldRepo

  defmodule P do 
    def tailor(base_query, options) when is_list(options) do 
      Enum.reduce(options, base_query, fn(option, query_so_far) ->
        tailor(query_so_far, option)
      end)
    end
    
    def tailor(query, {:with_ids, list}), do: query |> where([p], p.id in ^list)
  end

  ## PUBLIC

  def all_ordered(options \\ []) do
    query = from p in OldProcedure, order_by: fragment("lower(?)", p.name)

    query
    |> P.tailor(options)
    |> @repo.all
  end
end
