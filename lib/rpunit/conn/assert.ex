defmodule RoundingPegs.ExUnit.Conn.Assert do
  import RoundingPegs.ExUnit.CheckStyle
  import ExUnit.Assertions
  
  # This may only be used in controller tests, that do not use `bypass_through`.
  defchecker renders_template!(conn, which) do
    assert conn.private.phoenix_template == which
  end

  defchecker flash_matches!(conn, key, regexp) do
    assert conn.private.phoenix_flash[key] =~ regexp
  end
end
