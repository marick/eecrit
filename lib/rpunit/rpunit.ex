defmodule RoundingPegs.ExUnit do

  defmacro __using__(_) do
    quote do
      import RoundingPegs.ExUnit.Macros
      import RoundingPegs.ExUnit.Assertions
      import ShouldI, only: [assign: 2]
    end
  end
end
