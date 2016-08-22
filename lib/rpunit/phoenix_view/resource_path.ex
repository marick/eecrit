defmodule RoundingPegs.ExUnit.PhoenixView.ResourcePath do
  @moduledoc """
  Converts data in one of a variety of formats into a path using
  the path functions in Router.Helpers module.
  """
  alias RoundingPegs.ExUnit.PhoenixState

  def cast_to_path(action, %{fn: fn_name} = descriptor) do
    path_args = Map.get(descriptor, :args, [])
    params = Map.get(descriptor, :params, [])
    fn_args = [PhoenixState.get(:endpoint), action] ++ path_args ++ [params]
    apply(PhoenixState.get(:path_module), fn_name, fn_args)
  end

  def cast_to_path(action, %{model: model} = descriptor) do
    fn_name = PhoenixState.get(:path_fns) |> Map.get(model)
    cast_to_path(action, Map.put(descriptor, :fn, fn_name))
  end

  def cast_to_path(action, descriptor),
    do: cast_to_path(action, canonicalize(descriptor))

  
  def canonicalize(%{__struct__: model} = struct),
    do: %{model: model, args: [struct], params: []}

  def canonicalize([%{__struct__: model} = struct | params]), 
    do: %{model: model, args: [struct], params: params}

  def canonicalize(model_or_fn) when is_atom(model_or_fn) do
    if module_name?(model_or_fn) do 
      %{model: model_or_fn, args: [], params: []}
    else
      %{fn: model_or_fn, args: [], params: []}
    end
  end

  def canonicalize([model_or_fn | args_and_params] ) when is_atom(model_or_fn) do
    base = canonicalize(model_or_fn)
    {args, params} = Enum.split_while(args_and_params, fn(elt) ->
      not is_tuple(elt)
    end)
    %{base | args: args, params: params}
  end
  
  # private
  
  defp module_name?(atom) do
    atom
    |> Atom.to_string
    |> String.starts_with?("Elixir.")
  end
end
  
