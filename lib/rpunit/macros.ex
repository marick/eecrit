defmodule RoundingPegs.ExUnit.Macros do

  defmacro defchecker({_f, _, [first_arg | _more_args]} = head, do: body) do
    quote do
      def unquote(head) do
        unquote(body)
        unquote(first_arg)
      end
    end
  end

  defmacro provides(varlist) when is_list(varlist) do
    keys = Enum.map(varlist, (fn {name, _, _} -> name end))
    quote do
      {:ok, Enum.zip(unquote(keys), unquote(varlist))}
    end
  end

  defmacro provides({key, _, _} = var) do
    quote do
      {:ok, %{unquote(key) => unquote(var)}}
    end
  end
end
