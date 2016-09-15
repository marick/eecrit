defmodule Eecrit.ViewModel.Macros do
  defmacro def_view_model(name, keys, do: body) do
    defstruct_body = Enum.zip(keys, List.duplicate(nil, length(keys)))
    quote do
      defmodule unquote(name) do
        Module.put_attribute unquote(name), :required_keys, unquote(keys)
        Module.put_attribute unquote(name), :enforce_keys, unquote(keys)
        defstruct unquote(defstruct_body)
        def cast!(model, extras \\ []) do
          struct!(unquote(name), Map.take(model, unquote(keys)))
          |> Map.merge(Enum.into(extras, %{}))
        end
        unquote(body)
      end
    end
  end

  # The rigamarole with `singular` and `plural` is so the call
  # needn't prefix the function name with `:`. Is that a good idea?
  defmacro default_constructors(module, {singular, _, _}, {plural, _, _}) do
    quote do
      def unquote(singular)(x, extras \\ []) do
        unquote(module).cast!(x, extras)
      end

      def unquote(plural)(%Ecto.Association.NotLoaded{}), do: []

      def unquote(plural)(xs) do
        Enum.map(xs, fn x -> unquote(singular)(x) end)
      end

      defoverridable [
        {unquote(singular), 2}, {unquote(singular), 1}, {unquote(plural), 1}
      ]
    end
  end
end

defmodule Eecrit.ViewModel do
  import Eecrit.Router.Helpers
  use Phoenix.HTML
  require Eecrit.ViewModel.Macros
  import Eecrit.ViewModel.Macros

  defprotocol Protocol do
    @doc "Produce a link (<a>) to an expansive version"
    def link_to_more_detail(view_model, conn)
  end

  def_view_model Animal, [:name, :id] do
    defimpl Protocol, for: __MODULE__ do
      def link_to_more_detail(view_model, conn) do 
        link view_model.name,
          to: old_animal_path(conn, :show, view_model.id),
          title: "Show details for this animal"
      end
    end
  end

  def_view_model Procedure, [:name, :id] do
    defimpl Protocol, for: __MODULE__ do
      def link_to_more_detail(view_model, conn) do 
        link view_model.name,
          to: old_procedure_path(conn, :show, view_model.id),
          title: "Show details for this procedure"
      end
    end
  end

  def_view_model Reservation,
    [:course, :instructor, :time_bits, :date_range, :procedures] do
  end

  default_constructors(Animal, animal, animals)
  default_constructors(Procedure, procedure, procedures)

  default_constructors(Reservation, reservation, reservations)
  def reservation(model, extras \\ []) do
    model 
    |> Map.put(:date_range, date_range({Ecto.Date.to_iso8601(model.first_date),
                                       Ecto.Date.to_iso8601(model.last_date)}))
    |> Map.put(:procedures, procedures(model.procedures))
    |> super(extras)
  end

  # TODO: Settle on either one date-range format, or on one going down to
  # the database or one coming back up.
  def date_range(%{first_date: _first, last_date: _last} = range), do: range
  def date_range({first, last}), do: %{first_date: first, last_date: last}
  def date_range(:infinity), do: :infinity
  def date_range(nil), do: :infinity
  
end
