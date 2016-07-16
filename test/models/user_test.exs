defmodule Eecrit.UserTest do
  use Eecrit.ModelCase

  alias Eecrit.User

  @valid_attrs %{display_name: "Dawn Marick",
                 login_name: "dster@critter4us.com",
                 password: "password"}

  test "creating a user" do
    changeset = User.checking_creation_changeset(@valid_attrs)
    assert changeset.valid?
  end

  test "when creating a user, all fields are required" do
    changeset = User.checking_creation_changeset(%{})
    assert {:display_name, "can't be blank"} in flattened_errors(changeset)
    assert {:login_name, "can't be blank"} in flattened_errors(changeset)
    assert {:password, "can't be blank"} in flattened_errors(changeset)
  end
end
