defmodule RoundingPegs.ExUnit.View do
  require Phoenix.ConnTest
  @doc"""
  Like render_to_string because it also works with helpers that
  produce Phoenix-style iodata (which can contain `{:safe}` tuples).
  """
  def to_view_string(phoenix_iodata) do
    phoenix_iodata |> Phoenix.HTML.Safe.to_iodata |> IO.iodata_to_binary
  end

  # The default endpoint for testing (for constructing paths)
  @endpoint Eecrit.Endpoint

  # TODO: This does not include plugs specific to the controller
  def simulate_browser_routing(conn) do
    conn
    |> Phoenix.ConnTest.bypass_through(Eecrit.Router, :browser)
    |> Phoenix.ConnTest.get("..irrelevant..")
  end
end
