defmodule RoundingPegs.ExUnit.PhoenixView.PathMakerTest do
  use RoundingPegs.ExUnit.Case
  alias RoundingPegs.ExUnit.PhoenixView.PathMaker, as: S
  require Eecrit.Router.Helpers

  @path_fn :old_animal_path
  @model Eecrit.OldAnimal

  describe "the two types of canonical formats" do
    test "the fn-canonical format with args and params" do
      input_with_arg = %{fn: @path_fn,
                         args: [1],
                         params: [param1: "p1", param2: 8]}

      input_no_arg = %{fn: @path_fn,
                       args: [],
                       params: [param1: "p1"]}

      # anchors
      assert S.cast_to_path(:index, input_no_arg) == "/animals?param1=p1"
      assert S.cast_to_path(:new, input_no_arg) == "/animals/new?param1=p1"
      assert S.cast_to_path(:show, input_with_arg) == "/animals/1?param1=p1&param2=8"
      assert S.cast_to_path(:edit, input_with_arg) == "/animals/1/edit?param1=p1&param2=8"

      # forms
      assert S.cast_to_path(:create, input_no_arg) == "/animals?param1=p1"
      assert S.cast_to_path(:delete, input_with_arg) == "/animals/1?param1=p1&param2=8"
      assert S.cast_to_path(:update, input_with_arg) == "/animals/1?param1=p1&param2=8"
    end

    test "the fn-canonical format without params" do
      input_with_arg = %{fn: @path_fn, args: [1], params: []}
      input_no_arg = %{fn: @path_fn, args: [], params: []}

      # anchors
      assert S.cast_to_path(:index, input_no_arg) == "/animals"
      assert S.cast_to_path(:new, input_no_arg) == "/animals/new"
      assert S.cast_to_path(:show, input_with_arg) == "/animals/1"
      assert S.cast_to_path(:edit, input_with_arg) == "/animals/1/edit"

      # forms
      assert S.cast_to_path(:create, input_no_arg) == "/animals"
      assert S.cast_to_path(:delete, input_with_arg) == "/animals/1"
      assert S.cast_to_path(:update, input_with_arg) == "/animals/1"
    end

    test "the model-canonical format" do
      input_with_arg = %{model: @model, args: [1], params: [param1: "p1"]}
      input_no_arg = %{model: @model, args: [], params: []}

      assert S.cast_to_path(:index, input_no_arg) == "/animals"
      assert S.cast_to_path(:show, input_with_arg) == "/animals/1?param1=p1"
      assert S.cast_to_path(:create, input_no_arg) == "/animals"
    end
  end

  describe "noncanonical forms" do
    test "a lone structure" do
      animal = struct(@model, id: 383)
      assert S.canonicalize(animal) == %{model: @model, args: [animal], params: []}
      assert S.cast_to_path(:show, animal) == "/animals/383"
    end

    test "a structure with parameters" do
      animal = struct(@model, id: 383)
      input = [animal, param: 33]
      assert S.canonicalize(input) ==
        %{model: @model, args: [animal], params: [param: 33]}
      assert S.cast_to_path(:delete, input) == "/animals/383?param=33"
    end

    test "a model alone" do
      assert S.canonicalize(@model) == %{model: @model, args: [], params: []}
      assert S.cast_to_path(:new, @model) == "/animals/new"
    end

    test "a model with arguments and/or params" do
      empty_rest = [@model]
      assert S.canonicalize(empty_rest) == %{model: @model, args: [], params: []}
      assert S.cast_to_path(:index, empty_rest) == "/animals"

      just_args = [@model, 1]
      assert S.canonicalize(just_args) == %{model: @model, args: [1], params: []}
      assert S.cast_to_path(:update, just_args) == "/animals/1"

      just_params = [@model, p: "foo"]
      assert S.canonicalize(just_params) == %{model: @model, args: [], params: [p: "foo"]}
      assert S.cast_to_path(:new, just_params) == "/animals/new?p=foo"

      animal = struct(@model, id: 383)
      both = [@model, animal, p: "q", q: "p"]
      assert S.canonicalize(both) ==
        %{model: @model, args: [animal], params: [p: "q", q: "p"]}
      assert S.cast_to_path(:update, both) == "/animals/383?p=q&q=p"
    end

    test "an atom naming a path function" do
      assert S.canonicalize(@path_fn) == %{fn: @path_fn, args: [], params: []}
      assert S.cast_to_path(:new, @path_fn) == "/animals/new"
    end

    test "path functions can have args and params" do
      input = [@path_fn, 1, two: 2]
      assert S.canonicalize(input) == %{fn: @path_fn, args: [1], params: [two: 2]}
      assert S.cast_to_path(:edit, input) == "/animals/1/edit?two=2"
    end
  end
end
