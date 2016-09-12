defmodule Eecrit.OldAnimalSource do
  import Ecto.Query
  alias Eecrit.OldAnimal
  alias Eecrit.OldReservationSource
  alias Eecrit.OldReservation
  
  @repo Eecrit.OldRepo

  defmodule P do 
    def tailor(base_query, options) when is_list(options) do 
      Enum.reduce(options, base_query, fn(option, query_so_far) ->
        tailor(query_so_far, option)
      end)
    end
    
    def tailor(query, {:order_by_name, true}),
      do: from a in query, order_by: fragment("lower(?)", a.name)

    def tailor(query, {:include_out_of_service, true}), do: query
    def tailor(query, {:include_out_of_service, false}) do
      query
      |> where([a],
         is_nil(a.date_removed_from_service) or
         a.date_removed_from_service > fragment("CURRENT_DATE"))
    end

    def tailor(query, {:ever_in_service_during, {first_date, _}}) do
      query
      |> where([a],
         is_nil(a.date_removed_from_service) or
         a.date_removed_from_service >= ^Ecto.Date.cast!(first_date))
    end
  end

  ## PUBLIC
  
  # TODO: Have a "use NamedSource "superclass", together with procedures?

  def all(options \\ []) do
    OldAnimal
    |> P.tailor(options)
    |> @repo.all
  end

  def all_ordered(options \\ []) do 
    all [{:order_by_name, true} | options]
  end
end
