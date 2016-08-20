defmodule RoundingPegs.ExUnit.PhoenixView.ResourcePath do
  @moduledoc """
  Converts data in one of a variety of formats into a path using
  the path functions in Router.Helpers module.
  """
  alias RoundingPegs.ExUnit.PhoenixState

  def cast_to_path(path) when is_binary(path), do: path

  def cast_to_path(model, action, arglist, params) do
    path_fn = PhoenixState.get(:path_fns) |> Map.get(model)
    arglist = [PhoenixState.get(:endpoint), action] ++ arglist ++ [params]
    apply(PhoenixState.get(:path_module), path_fn, arglist)
  end
end
  
