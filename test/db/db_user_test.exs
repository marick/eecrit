defmodule Eecrit.Db.UserRepoTest do
  use Eecrit.ModelCase
  alias Eecrit.User

  @valid_attrs %{display_name: "Dawn Marick",
                 login_name: "dster@critter4us.com",
                 password: "password"}

  test "there is a unique constraint on the username" do
    insert_user(login_name: @valid_attrs.login_name)

    changeset = User.create_action_changeset(@valid_attrs)
    assert {:error, changeset} = Repo.insert(changeset)
    assert {:login_name, "has already been taken"} in flattened_errors(changeset)
  end

  @tag :skip
  test "the same is true of creation" do
  end

  @tag :skip
  test "constaints on current organization?" do
  end
end
