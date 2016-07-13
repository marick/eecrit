defmodule Eecrit.UserTest do
  use Eecrit.ModelCase

  alias Eecrit.User

  @valid_attrs %{display_name: "Dawn Marick",
                 login_name: "dster@critter4us.com",
                 password: "password"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  @tag :skip
  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
