defmodule Eecrit.TimeUtilTest do
  defstruct first: nil, last: nil
  alias Eecrit.TimeUtil, as: S
  use ExUnit.Case

  test "cast_to_date!" do
    expected = ~D[2012-01-23]
    assert S.cast_to_date!(expected) == expected
    assert S.cast_to_date!({2012, 1, 23}) == expected
    assert S.cast_to_date!(Ecto.Date.cast!("2012-01-23")) == expected
    assert S.cast_to_date!("2012-01-23") == expected
  end

  test "cast_to_erl!" do
    expected = {2012, 1, 23}
    assert S.cast_to_erl!(expected) == expected
    assert S.cast_to_erl!(~D[2012-01-23]) == expected
    assert S.cast_to_erl!(Ecto.Date.cast!("2012-01-23")) == expected
    assert S.cast_to_erl!("2012-01-23") == expected
  end

  test "adjust_range" do
    nine = ~D[2012-01-09]
    ten = ~D[2012-01-10]
    eleven = ~D[2012-01-11]
    nineteen = ~D[2012-01-19]
    twenty = ~D[2012-01-20]
    twentyone = ~D[2012-01-21]

    bounds = {ten, twenty}
    assert S.adjust_range(bounds, within: bounds) == bounds
    assert S.adjust_range({nine, twentyone}, within: bounds) == bounds
    assert S.adjust_range({eleven, nineteen}, within: bounds) == {eleven, nineteen}

    assert S.adjust_range({nine, eleven}, within: bounds) == {ten, eleven}
    assert S.adjust_range({nineteen, twentyone}, within: bounds) == {nineteen, twenty}

    # Works with other formats
    nine = Ecto.Date.cast!(nine)
    ten = Ecto.Date.cast!(ten)
    twenty = Ecto.Date.cast!(twenty)
    twentyone = Ecto.Date.cast!(twentyone)
    bounds = {ten, twenty}
    assert S.adjust_range({nine, twentyone}, within: bounds) == bounds
  end

  test "adjust_range_in_struct" do
    nine = ~D[2012-01-09]
    ten = ~D[2012-01-10]
    twenty = ~D[2012-01-20]
    twentyone = ~D[2012-01-21]

    bounds = {ten, twenty}
    source = %__MODULE__{first: nine, last: twentyone}
    expected = %__MODULE__{first: ten, last: twenty}
    
    assert S.adjust_range_in_struct(source, {:first, :last}, within: bounds) ==
      expected
  end

  test "days_covered" do
    day = ~D[2012-12-30]
    next_day = {2012, 12, 31}
    even_later = Ecto.Date.cast!("2013-01-01")

    assert S.days_covered({day, day}) == 1
    assert S.days_covered({day, next_day}) == 2
    assert S.days_covered({day, even_later}) == 3
  end
end
