defmodule Eecrit.AnimalTest do
  use Eecrit.ModelCase
  alias Eecrit.Animal

  @valid_attrs %{date_acquired: %{day: 17, month: 4, year: 2010}, date_removed: %{day: 17, month: 4, year: 2010}, kvs: "some content", name: "some content", tags: []}
  @empty_attrs %{}

  # test "a changeset for the `new` action" do
  #   changeset = Animal.new_action_changeset
  #   refute changeset.valid?
  # end

  # test "a changeset for the `create` action accepts valid attributes" do 
  #   changeset = Animal.create_action_changeset(@valid_attrs)
  #   assert changeset.valid?
  # end
  
  # test "a changeset for the `create` action rejects missing attributes" do 
  #   changeset = Animal.create_action_changeset(@empty_attrs)
  #   refute changeset.valid?
  # end

  # test "an edit changeset contains the original attributes" do
  #   org = struct(Animal, @valid_attrs)
  #   changeset = Animal.edit_action_changeset(org)
  #   assert changeset.valid?
  #   assert changeset.data == org
  # end

  # test "an update changeset processes update values" do
  #   org = struct(Animal, @valid_attrs)
  #   updates = %{fixme: "please"}  # You must add appropriate selected updates
  #   changeset = Animal.update_action_changeset(org, updates)
  #   assert changeset.valid?
  #   assert changeset.changes == updates
  # end

  # test "an update changeset rejects bad values" do
  #   org = struct(Animal, @valid_attrs)
  #   invalids = %{fixme: "please"} # You must add appropriate invalid values
  #   changeset = Animal.update_action_changeset(org, invalids)
  #   refute changeset.valid?
  #   assert Keyword.get(changeset.errors, :fixme)  # Fix this
  # end
end
