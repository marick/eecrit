defmodule Eecrit.OldGroupTest do
  use Eecrit.ModelCase
  alias Eecrit.OldGroup

  @valid_attrs %{reservation_id: 3}
  @empty_attrs %{}
  
  test "a changeset for the `create` action accepts valid attributes" do 
    changeset = OldGroup.create_action_changeset(@valid_attrs)
    assert changeset.valid?
  end
  
  test "a changeset for the `create` action rejects missing attributes" do 
    changeset = OldGroup.create_action_changeset(@empty_attrs)
    refute changeset.valid?
  end
end
