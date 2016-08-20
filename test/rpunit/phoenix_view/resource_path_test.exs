defmodule RoundingPegs.ExUnit.PhoenixView.ResourcePathTest do
  use ExUnit.Case
  require Eecrit.Router.Helpers
  require Eecrit.Endpoint
  alias Eecrit.OldAnimal
  alias RoundingPegs.ExUnit.PhoenixView.ResourcePath

  describe "cast_to_path" do 
    test "A plain string is left unconverted" do
      assert ResourcePath.cast_to_path("string") == "string"
    end
    
    test "most expansive format" do
      assert ResourcePath.cast_to_path(OldAnimal, :index, [], param1: 1, param2: "param2") ==
        "/animals?param1=1&param2=param2"
    end    
  end
end
