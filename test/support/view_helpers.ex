defmodule Eecrit.Test.ViewHelpers do
  import ExUnit.Assertions
  require Phoenix.ConnTest
  require ShouldI

  # Used for path generation
  @endpoint Eecrit.Endpoint


  def should_contain_link(html, {link_text, link_path}) do
    node = find_one_href(html, link_path)
    assert Floki.text(node) == link_text
    html
  end
  
  def should_contain_link_path(html, link_path) do
    assert find_one_href(html, link_path)
    html
  end

  def should_contain_link_text(html, link_text) do
    # Collect all link texts and check whether they contain text
    nodes = Floki.find(html, "a") 
    assert Floki.text(nodes) =~ link_text
    html
  end




  
  def assert_outgoing_links(conn, instructions) do
    html = only_main_html(conn.resp_body)
    for instruction <- instructions do
      if is_binary(instruction) do
        should_contain_link_path(html, instruction)
      else
        should_contain_link(html, instruction)
      end
    end
  end

  def assert_outgoing_link_texts(conn, texts) do
    html = only_main_html(conn.resp_body)
    for text <- texts, do: should_contain_link_text(html, text)
  end

  # private

  defp find_one_href(html, link_path) do
    nodes = Floki.find(html, "a[href='#{link_path}']")
    if length(nodes) == 0 do 
      flunk("No link to #{link_path}")
    else
      # Note: it's proven less of a hassle to find at least one than
      # to try to distinguish between the "more than one is an error" and
      # "more than one is OK" cases.
      List.first(nodes)
    end
  end

  defp only_main_html(html), do: Floki.find(html, "main") |> Floki.raw_html

end

