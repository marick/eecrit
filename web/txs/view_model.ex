defmodule Eecrit.ViewModel.Macros do
  defmacro def_view_model(name, keys, do: body) do
    defstruct_body = Enum.zip(keys, List.duplicate(nil, length(keys)))
    quote do
      defmodule unquote(name) do
        Module.put_attribute unquote(name), :required_keys, unquote(keys)
        Module.put_attribute unquote(name), :enforce_keys, unquote(keys)
        defstruct unquote(defstruct_body)
        def cast_list!(models), do: Enum.map(models, &cast!/1)
        def cast!(model, extras \\ []) do
          struct!(unquote(name), Map.take(model, unquote(keys)))
          |> Map.merge(Enum.into(extras, %{}))
        end
        unquote(body)
      end
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

  def animal(x, extras \\ []), do: Animal.cast!(x, extras)
  def animals(xs), do: Animal.cast_list!(xs)

  def procedure(x, extras \\ []), do: Procedure.cast!(x, extras)
  def procedures(%Ecto.Association.NotLoaded{}), do: []
  def procedures(xs), do: Procedure.cast_list!(xs)

  def reservation(list) when is_list(list), do: Enum.map(list, &reservation/1)
  def reservation(%Eecrit.OldReservation{} = model) do
    model 
    |> Map.take([:course, :instructor, :time_bits])
    |> Map.put(:date_range, date_range({Ecto.Date.to_iso8601(model.first_date),
                                       Ecto.Date.to_iso8601(model.last_date)}))
    |> Map.put(:procedures, procedures(model.procedures))
  end

  def date_range(%{first_date: _first, last_date: _last} = range), do: range
  def date_range({first, last}), do: %{first_date: first, last_date: last}
  def date_range(:infinity), do: :infinity
  def date_range(nil), do: :infinity
  
end
