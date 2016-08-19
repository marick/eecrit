defmodule RoundingPegs.ExUnit.PhoenixView do
  defmacro __using__(_) do
    quote do
      import RoundingPegs.ExUnit.PhoenixView.Act
      import RoundingPegs.ExUnit.PhoenixView.Assert
      import RoundingPegs.ExUnit.PhoenixView.Arrange
    end
  end
end
