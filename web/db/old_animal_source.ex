defmodule Eecrit.OldAnimalSource do
  import Ecto.Query
  alias Eecrit.OldAnimal
  
  @repo Eecrit.OldRepo

  defmodule NoJoin do
    def base, do: OldAnimal
    
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

    def tailor(query, {:animal, animal}) do
      query
      |> where([a], a.id == ^animal)
    end
    
    def tailor(query, {:preload, preloads}), do: preload(query, ^preloads)

    def tailor(base_query, options) when is_list(options) do 
      Enum.reduce(options, base_query, fn(option, query_so_far) ->
        tailor(query_so_far, option)
      end)
    end
  end

  defmodule AnimalWithReservations do
    def base(id) do 
      from a in OldAnimal,
        where: a.id == ^id,
        join: r in assoc(a, :reservations)
    end

    def tailor(query, {:date_range, bounds}) do
      # TODO: Note that this duplicates - almost - code in
      # old_reservation_source. Figure out how to compose that
      # assuming-no-join function with this code that assumes a join.
      {first_date_inclusive, last_date_inclusive} = bounds
      first = Ecto.Date.cast!(first_date_inclusive)
      last = Ecto.Date.cast!(last_date_inclusive)
      
      from [a, r] in query,
        where: fragment("(?, ? + interval '1 day') OVERLAPS (?, ? + interval '1 day')",
          r.first_date, r.last_date,
          type(^first, :date), type(^last, :date))
    end

    def tailor(query, :include_procedures) do
      # It's interesting that if you have a separate `reservations` preload
      # up where the animal is joined to the reservation, you end up with
      # three more queries than leaving it out and just using the below.
      from [a, r] in query,
        join: p in assoc(r, :procedures),
        preload: [reservations: {r, procedures: p}]
    end

    def tailor(base_query, options) when is_list(options) do 
      Enum.reduce(options, base_query, fn(option, query_so_far) ->
        tailor(query_so_far, option)
      end)
    end

    # If an animal has no reservation, the query will return nil. In this case,
    # we fake an empty-reservations result.
    # 
    # NOTE: It is tempting to use left joins to avoid no query result when
    # an animal has no reservations. However, you'll still get that in the
    # case where you're using a date range because the WHERE clause will
    # filter all results out.
    def run_query(query, repo, id), 
      do: repo.one(query) || (repo.get(OldAnimal, id) |> Map.put(:reservations, []))
  end

  ## PUBLIC
  
  # TODO: Have a "use NamedSource "superclass", together with procedures?

  def all(options \\ []) do
    NoJoin.base
    |> NoJoin.tailor(options)
    |> @repo.all
  end

  def all_ordered(options \\ []) do 
    all [{:order_by_name, true} | options]
  end

  
  # TODO: Figure out how to organize animal-alone and animal+reservation
  # tailoring.

  def animal_with_reservations(id, options \\ []) do
    AnimalWithReservations.base(id)
    |> AnimalWithReservations.tailor([:include_procedures | options])
    |> AnimalWithReservations.run_query(@repo, id)
  end    
end
