defmodule RoundingPegs.ExUnit.View do
  require Phoenix.ConnTest
  @doc"""
  Preferable to render_to_string because also works with helpers that
  produce Phoenix-style iodata (which can contain `{:safe}` tuples.
  """
  def to_view_string(phoenix_iodata) do
    phoenix_iodata |> Phoenix.HTML.Safe.to_iodata |> IO.iodata_to_binary
  end

  def render_view_helper(conn, f, args \\ []) do
    apply(f, [conn | args]) |> to_view_string
  end
end
