defmodule RoundingPegs.CheckStyle do
  @moduledoc """
  Maybe someday this will be support for Midje-style checkers in ExUnit.
  """

  def evenish?(actual), do: 3

  def do_call(module, method, actual) do
    apply(module, method, [actual])
  end
  defmacro check(actual, {{:., _, [{:__aliases__, _, aliases}, f]}, _, _}) do
    module = Module.concat(aliases)

    IO.puts 1
    quote do
      do_call(unquote(module), unquote(f), unquote(actual))
    end
  end

  defmacro check(actual, {f, _, _}) do
    IO.puts 2
    quote do
      do_call(__MODULE__, unquote(f), unquote(actual))
    end
  end
  
  
  # defmacro check(actual, checker) do
  #   IO.puts inspect(checker)
  #   IO.puts apply(RoundingPegs.ExUnitPlus, :evenish?, [8])
  #   # quote do
  #   #   apply(checker, [actual])
  #   # end
  # end
end
