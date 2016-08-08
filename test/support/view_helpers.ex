defmodule Eecrit.Test.ViewHelpers do
  import ExUnit.Assertions

  def safe_substring(safe_result, substring) do
    content = Phoenix.HTML.safe_to_string(safe_result)
    assert String.contains?(content, substring)
  end

  def assert_outgoing_links(conn, instructions) do
    response = conn.resp_body
    for instruction <- instructions do
      case instruction do
        {link_text, link_path} -> 
          assert response =~ (link_path <> ~s{">} <> link_text)
        link_path ->
          assert response =~ link_path
      end
    end
  end
end

