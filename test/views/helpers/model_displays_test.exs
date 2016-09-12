defmodule Eecrit.ModelDisplaysTest do
  alias Eecrit.ModelDisplays, as: S
  use ExUnit.Case

  test "date formatting" do
    assert S.date(nil) == ""

    expected = "January 23, 2012"
    assert S.date(~D[2012-01-23]) == expected
    assert S.date({2012, 1, 23}) == expected
    assert S.date(Ecto.Date.cast!("2012-01-23")) == expected
  end

  test "date range formatting" do
    earlier = ~D[2012-01-23]
    later = ~D[2013-12-23]
    assert S.date_range({earlier, later}) ==
      "from January 23, 2012 through December 23, 2013"

    # alternate format
    assert S.date_range(%{first_date: earlier, last_date: later}) ==
      S.date_range({earlier, later})

    # Single-day range
    assert S.date_range({earlier, earlier}) == "on January 23, 2012"
  end

  test "date ranges without prefixes" do
    assert S.date_range_without_prefix({~D[2012-01-23], ~D[2013-12-23]}) == 
      "January 23, 2012 through December 23, 2013"
    assert S.date_range_without_prefix(%{first_date: ~D[2012-01-23], last_date: ~D[2013-12-23]}) == 
      "January 23, 2012 through December 23, 2013"
    assert S.date_range_without_prefix({~D[2012-01-23], ~D[2012-01-23]}) ==
      "January 23, 2012"
  end

  test "times formatting" do
    assert S.times("000") == "never"
    assert S.times("001") == "evening"
    assert S.times("010") == "afternoon"
    assert S.times("100") == "morning"
    assert S.times("110") == "morning and afternoon"
    assert S.times("101") == "morning and evening"
    assert S.times("011") == "afternoon and evening"
    assert S.times("111") == "morning, afternoon, and evening"
  end
end
