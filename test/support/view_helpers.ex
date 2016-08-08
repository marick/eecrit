defmodule Eecrit.Test.ViewHelpers do
  import ExUnit.Assertions

  def safe_substring(safe_result, substring) do
    content = Phoenix.HTML.safe_to_string(safe_result)
    assert String.contains?(content, substring)
  end

  def assert_outgoing_links(conn, tuples) do
    response = conn.resp_body
    for {link_text, link_path} <- tuples do
      assert response =~ (link_path <> ~s{">} <> link_text)
    end
  end
end

