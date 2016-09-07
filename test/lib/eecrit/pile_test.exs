defmodule Eecrit.PileTest do
  use ExUnit.Case
  alias Eecrit.Pile, as: S

  test "index" do
    maps = [%{id: 1, m: 2}, %{id: 2, m: 3}]
    assert S.index(maps, :id) == %{1 => %{id: 1, m: 2}, 2 => %{id: 2, m: 3}}
  end
end
