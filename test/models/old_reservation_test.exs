defmodule Eecrit.OldReservationTest do
  use Eecrit.ModelCase
  alias Eecrit.OldReservation

  @valid_attrs %{course: "vcm334",
                 first_date: Ecto.Date.cast!("2001-01-01"),
                 last_date: Ecto.Date.cast!("2012-12-12"),
                }
  @empty_attrs %{}
  
  test "a changeset for the `create` action accepts valid attributes" do 
    changeset = OldReservation.create_action_changeset(@valid_attrs)
    assert changeset.valid?
  end
  
  test "a changeset for the `create` action rejects missing attributes" do 
    changeset = OldReservation.create_action_changeset(@empty_attrs)
    refute changeset.valid?
  end

end
