defmodule Eecrit.OldUseTest do
  use Eecrit.ModelCase
  alias Eecrit.OldUse

  @valid_attrs %{animal_id: 1, procedure_id: 2, group_id: 3}
  @empty_attrs %{}
  
  test "a changeset for the `create` action accepts valid attributes" do 
    changeset = OldUse.create_action_changeset(@valid_attrs)
    assert changeset.valid?
  end
  
  test "a changeset for the `create` action rejects missing attributes" do 
    changeset = OldUse.create_action_changeset(@empty_attrs)
    refute changeset.valid?
  end
end
