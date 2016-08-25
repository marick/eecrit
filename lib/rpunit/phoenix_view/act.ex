defmodule RoundingPegs.ExUnit.PhoenixView.Act do
  @doc"""
  Like render_to_string because it also works with helpers that
  produce Phoenix-style iodata (which can contain `{:safe}` tuples).
  """
  def to_view_string(phoenix_iodata) do
    phoenix_iodata |> Phoenix.HTML.Safe.to_iodata |> IO.iodata_to_binary
  end

end
