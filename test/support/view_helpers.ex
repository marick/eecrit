defmodule Eecrit.Test.ViewHelpers do
  import ExUnit.Assertions
  require Phoenix.ConnTest
  require ShouldI

  @doc"""
  Preferable to render_to_string because also works with helpers that
  produce Phoenix-style iodata (which can contain `{:safe}` tuples.
  """
  def to_view_string(phoenix_iodata) do
    phoenix_iodata |> Phoenix.HTML.Safe.to_iodata |> IO.iodata_to_binary
  end

  def render_view_with_layout(conn, view_module, template) do
    assigns = %{layout: {Eecrit.LayoutView, "app.html"},
                conn: conn}
    Phoenix.View.render(view_module, template, assigns) |> to_view_string
  end    

  def render_layout(conn),
      do: render_view_with_layout(conn, Eecrit.EmptyView, "index.html")

  def render_view_helper(conn, f, args \\ []) do
    apply(f, [conn | args]) |> to_view_string
  end


  # TODO: get rid of this
  def safe_substring(safe_result, substring) do
    content = Phoenix.HTML.safe_to_string(safe_result)
    assert String.contains?(content, substring)
  end


  # Working with links

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


  def should_not_contain_link(html, {link_text, link_path}) do
    html
    |> should_not_contain_link_path(link_path)
    |> should_not_contain_link_text(link_text)
    html
  end

  def should_not_contain_link_path(html, link_path) do
    nodes = Floki.find(html, "a[href='#{link_path}']")
    assert length(nodes) == 0, "There are links to #{link_path}"
    html
  end

  def should_not_contain_link_text(html, link_text) do
    # Collect all link texts and check whether they contain text
    nodes = Floki.find(html, "a") 
    refute Floki.text(nodes) =~ link_text
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


  @endpoint Eecrit.Endpoint

  def simulate_routing(conn) do
    conn
    |> Phoenix.ConnTest.bypass_through(Eecrit.Router, :browser)
    |> Phoenix.ConnTest.get("..irrelevant..")
  end
end

