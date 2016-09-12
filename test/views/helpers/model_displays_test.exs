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

end
