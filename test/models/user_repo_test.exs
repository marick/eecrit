defmodule Eecrit.UserRepoTest do
  use Eecrit.ModelCase
  alias Eecrit.User

  @valid_attrs %{display_name: "Dawn Marick",
                 login_name: "dster@critter4us.com",
                 password: "password"}

  test "there is a unique constraint on the username" do
    insert_user(login_name: @valid_attrs.login_name)

    changeset = User.checking_creation_changeset(@valid_attrs)
    assert {:error, changeset} = Repo.insert(changeset)
    assert {:login_name, "has already been taken"} in flattened_errors(changeset)
  end
end
