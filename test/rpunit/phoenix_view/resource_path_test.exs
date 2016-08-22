defmodule RoundingPegs.ExUnit.PhoenixView.ResourcePathTest do
  use RoundingPegs.ExUnit.Case
  require Eecrit.Router.Helpers
  require Eecrit.Endpoint
  alias Eecrit.OldAnimal
  alias RoundingPegs.ExUnit.PhoenixView.ResourcePath

  @path_fn :old_animal_path
  @model Eecrit.OldAnimal

  describe "the two types of canonical formats" do

    setup context, do: assign context, subject: &ResourcePath.cast_to_path/2

    test "the fn-canonical format with args and params", %{subject: subject}  do
      input_with_arg = %{fn: @path_fn,
                         args: [1],
                         params: [param1: "p1", param2: 8]}

      input_no_arg = %{fn: @path_fn,
                       args: [],
                       params: [param1: "p1"]}

      # anchors
      assert subject.(:index, input_no_arg) == "/animals?param1=p1"
      assert subject.(:new, input_no_arg) == "/animals/new?param1=p1"
      assert subject.(:show, input_with_arg) == "/animals/1?param1=p1&param2=8"
      assert subject.(:edit, input_with_arg) == "/animals/1/edit?param1=p1&param2=8"

      # forms
      assert subject.(:create, input_no_arg) == "/animals?param1=p1"
      assert subject.(:delete, input_with_arg) == "/animals/1?param1=p1&param2=8"
      assert subject.(:update, input_with_arg) == "/animals/1?param1=p1&param2=8"
    end

    test "the fn-canonical format without params", %{subject: subject}  do
      input_with_arg = %{fn: @path_fn, args: [1], params: []}
      input_no_arg = %{fn: @path_fn, args: [], params: []}

      # anchors
      assert subject.(:index, input_no_arg) == "/animals"
      assert subject.(:new, input_no_arg) == "/animals/new"
      assert subject.(:show, input_with_arg) == "/animals/1"
      assert subject.(:edit, input_with_arg) == "/animals/1/edit"

      # forms
      assert subject.(:create, input_no_arg) == "/animals"
      assert subject.(:delete, input_with_arg) == "/animals/1"
      assert subject.(:update, input_with_arg) == "/animals/1"
    end

    test "the model-canonical format", %{subject: subject} do
      input_with_arg = %{model: @model, args: [1], params: [param1: "p1"]}
      input_no_arg = %{model: @model, args: [], params: []}

      assert subject.(:index, input_no_arg) == "/animals"
      assert subject.(:show, input_with_arg) == "/animals/1?param1=p1"
      assert subject.(:create, input_no_arg) == "/animals"
    end    
  end
end


    # test "most expansive format - the different actions" do
    #   # These are anchors.
    #   # index
    #   input = [OldAnimal, :index, [], [param1: 1, param2: "param2"]]
    #   assert run(input) == "/animals?param1=1&param2=param2"

    #   # show
    #   input = [OldAnimal, :show, [1001], [param1: 1, param2: "param2"]]
    #   assert run(input) == "/animals/1001?param1=1&param2=param2"

    #   # new
    #   input = [OldAnimal, :new, [], [param1: 1, param2: "param2"]]
    #   assert run(input) == "/animals/new?param1=1&param2=param2"

    #   # edit
    #   input = [OldAnimal, :edit, [1001], [param1: 1, param2: "param2"]]
    #   assert run(input) == "/animals/1001/edit?param1=1&param2=param2"

    #   # These are forms - the paths are only a part of what needs checking
    #   # create
    #   input = [OldAnimal, :create, [], [param1: 1, param2: "param2"]]
    #   assert run(input) == "/animals?param1=1&param2=param2"

    #   # update
    #   input = [OldAnimal, :update, [1001], [param1: 1, param2: "param2"]]
    #   assert run(input) == "/animals/1001?param1=1&param2=param2"

    #   # delete 
    #   input = [OldAnimal, :delete, [1001], [param1: 1, param2: "param2"]]
    #   assert run(input) == "/animals/1001?param1=1&param2=param2"
    # end

    # @tag :skip
    # test "most expansive format - special-case values for args" do 
    #   # instances can be used instead of specific path values
    #   input = [OldAnimal, :show, [%OldAnimal{id: 1001}], [param1: 1, param2: "param2"]]
    #   assert run(input) == "/animals/1001?param1=1&param2=param2"

    #   # empty parameters
    #   input = [OldAnimal, :edit, [%OldAnimal{id: 1001}], []]
    #   assert run(input) == "/animals/1001/edit"
