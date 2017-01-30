defmodule Eecrit.AnimalsTest do
  use ExUnit.Case, async: true
  alias Eecrit.Animals
  alias Eecrit.AnimalDeltas

  setup do
    {:ok, animals} = Animals.start_link(:_unused_name)
    {:ok, animals: animals}
  end

  test "initialized", %{animals: animals} do
    assert Enum.count(Animals.all) == 4
  end
end
