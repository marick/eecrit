defmodule Eecrit.UserTest do
  use Eecrit.ModelCase

  alias Eecrit.User

  @valid_attrs %{display_name: "Dawn Marick",
                 login_name: "dster@critter4us.com",
                 password: "password"}
  @empty_attrs %{}
  @invalid_attrs %{password: "12345"}


  ### New
  test "a changeset for the `new` action" do
    changeset = User.new_action_changeset
    refute changeset.valid?
  end

  ### Create
  test "a changeset for the `create` action accepts valid attributes" do 
    changeset = User.create_action_changeset(@valid_attrs)
    assert changeset.valid?
  end
  
  test "creation hashes the password" do
    changeset = User.create_action_changeset(@valid_attrs)
    assert String.length(changeset.changes.password_hash) > 50
    refute changeset.changes.password_hash == changeset.changes.password
  end

  test "a changeset for the `create` action rejects missing attributes" do 
    changeset = User.create_action_changeset(@empty_attrs)
    errors = flattened_errors(changeset)
    assert {:display_name, "can't be blank"} in errors
    assert {:login_name, "can't be blank"} in errors
    assert {:password, "can't be blank"} in errors
    refute changeset.valid?
  end

  test "creation requires more than just the existence of fields" do
    changeset = User.create_action_changeset(@invalid_attrs)
    errors = flattened_errors(changeset)
    refute changeset.valid?
    assert {:display_name, "should be at most 255 character(s)"} in errors
    assert {:login_name, "should be at most 255 character(s)"} in errors
    assert {:password, "should be at least 6 character(s)"} in errors
  end

  # Edit
  test "an edit changeset contains the original attributes" do
    user = struct(User, @valid_attrs)
    changeset = User.edit_action_changeset(user)
    assert changeset.valid?
    assert changeset.data == user
  end

  # Update
  test "an update changeset processes update values" do
    user = struct(User, @valid_attrs)
    updates = %{display_name: "new display name"}
    changeset = User.update_action_changeset(user, updates)
    assert changeset.valid?
    assert changeset.changes == updates
  end

  test "updating hashes the password" do
    user = struct(User, @valid_attrs)
    updates = %{password: "new password"}
    changeset = User.update_action_changeset(user, updates)

    assert String.length(changeset.changes.password_hash) > 50
    refute changeset.changes.password_hash == changeset.changes.password
  end

  test "an update changeset rejects blank values" do
    user = struct(User, @valid_attrs)
    updates = %{display_name: ""}
    changeset = User.update_action_changeset(user, updates)
    refute changeset.valid?
    assert {:display_name, "can't be blank"} in flattened_errors(changeset)
  end

  test "updating requires more than just the existence of fields" do
    user = struct(User, @valid_attrs)
    changeset = User.update_action_changeset(user, @invalid_attrs)
    errors = flattened_errors(changeset)
    refute changeset.valid?
    assert {:display_name, "should be at most 255 character(s)"} in errors
    assert {:login_name, "should be at most 255 character(s)"} in errors
    assert {:password, "should be at least 6 character(s)"} in errors
  end

end
