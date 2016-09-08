defmodule Eecrit.OldProcedureSourceTest do
  use Eecrit.ModelCase
  alias Eecrit.OldProcedureSource

  def run(options \\ []),
    do: OldProcedureSource.all_ordered(options) |> Enum.map(&Map.get(&1, :name))
  
  test "returns human-style alphabetical ordering" do
    insert_old_procedure(name: "ab")
    insert_old_procedure(name: "AA")
    insert_old_procedure(name: "Z")
    insert_old_procedure(name: "m")
    insert_old_procedure(name: "12")
    
    assert run == ["12", "AA", "ab", "m", "Z"]
  end

  test "can ask for a specific set of ids" do
    z = insert_old_procedure(name: "Z")
    m = insert_old_procedure(name: "m")
    insert_old_procedure(name: "12")

    assert run(with_ids: [z.id, m.id]) == ["m", "Z"]
  end
end
