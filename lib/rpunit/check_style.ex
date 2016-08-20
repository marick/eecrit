defmodule RoundingPegs.ExUnit.CheckStyle do
  @moduledoc """
  Maybe someday this will be support for Midje-style checkers in ExUnit.
  """

  defmacro defchecker({_f, _, [first_arg | _more_args]} = head, do: body) do
    quote do
      def unquote(head) do
        unquote(body)
        unquote(first_arg)
      end
    end
  end
end
