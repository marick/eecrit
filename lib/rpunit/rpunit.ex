defmodule RoundingPegs.ExUnit.Case do

  defmacro __using__(_) do
    quote do
      use ExUnit.Case
      import ShouldI, only: [assign: 2]
    end
  end
end
