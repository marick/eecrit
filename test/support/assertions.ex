defmodule Eecrit.Test.Assertions do
  import ExUnit.Assertions

  # Use of assert in following is a quick and dirty way to get good error messages.
  # They're still used with the assert macro in the test, just for consistency.


  # This may only be used in controller tests, that do not use `bypass_through`.
  def renders_template(conn, which) do
    assert conn.private.phoenix_template == which
    true
  end
end
