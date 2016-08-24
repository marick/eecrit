defmodule RoundingPegs.ExUnit.AssertionsTest do
  use RoundingPegs.ExUnit.Case
  import RoundingPegs.ExUnit.Assertions

  describe "assert_exception" do
    test "can match on strings using =~ substring" do
      assert_exception "partial", do: raise "Expect a partial match"
    end

    test "can match on regexes" do
      assert_exception ~r/pa..ial/, do: raise "Expect a partial match"
    end

    test "can match on exception 'type'" do
      assert_exception RuntimeError, do: raise "Expect a partial match"
    end

    test "can match on combinations of the above" do
      assert_exception [RuntimeError, "partial"], do: raise "Expect a partial match"
    end

    test "it does actually catch errors" do
      assert_raise ExUnit.AssertionError, fn -> 
        assert_exception NotRuntimeError, do: raise "busted"
      end

      assert_raise ExUnit.AssertionError, fn -> 
        assert_exception [RuntimeError, "diff"], do: raise "busted"
      end
    end
  end
  
  describe "matches!" do
    test "has same checking behavior as =~" do 
      assert matches!("exact match", "exact match") == "exact match"
      assert matches!("exact match", "match") == "exact match"
      assert matches!("exact match", ~r/exact+ mat+[bc]h/) == "exact match"
    end

    test "can be chained" do
      result =
        "exact match"
        |> matches!("exact match")
        |> matches!("match")
        |> matches!(~r/ct+ mat+[bc]h/)
      assert result == "exact match"
    end

    test "fails with same information as ExUnix assert" do
      assert_exception [~s{code: actual =~ "ab" <> "cd"},
                        ~s{lhs:  "some string"},
                        ~s{rhs:  "abcd"}] do 
        "some string" |> matches!("ab" <> "cd")
      end
    end
  end
end
