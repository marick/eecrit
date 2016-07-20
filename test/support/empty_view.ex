defmodule Eecrit.EmptyView do
  @moduledoc """
  Use this view when testing layouts. Instead of rendering based on a
  file, it just renders an empty string.
  """
  use Eecrit.Web, :view

  def render(_template, _assigns), do: ""
end
