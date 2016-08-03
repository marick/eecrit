defmodule Eecrit.Test.ViewHelpers do
  import ExUnit.Assertions

  def safe_substring(safe_result, substring) do
    content = Phoenix.HTML.safe_to_string(safe_result)
    assert String.contains?(content, substring)
  end

end

