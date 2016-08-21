defmodule RoundingPegs.ExUnit.PhoenixView.ResourcePath do
  @moduledoc """
  Converts data in one of a variety of formats into a path using
  the path functions in Router.Helpers module.
  """
  alias RoundingPegs.ExUnit.PhoenixState

  @doc """
  ## Examples

      iex> animal_path(conn, :index) |> cast_to_path
      "/animals"

  """
  def cast_to_path(path) when is_binary(path), do: path

  @doc """
  ## Examples

      iex> cast_to_path(:index, Animal)
      "/animals"

      iex> cast_to_path(:index, %Animal{...})
      "/animals"

      iex> cast_to_path(:show, [Animal, 1])
      "/animals/1"

      iex> cast_to_path(:show, [Animal, %Animal{id: 1, ...}])
      "/animals/1"

      iex> cast_to_path(:show, %Animal{id: 1, ...})
      "/animals/1"

      iex> cast_to_path(:delete, [:session_path, 3])
      "/sessions/3"


      %{model: OldAnimal, args: [], params: []}
      %{fn: :animal_path, args: [], params: []}
      
  """

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
end
  
