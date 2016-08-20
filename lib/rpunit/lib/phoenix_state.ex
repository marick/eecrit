defmodule RoundingPegs.ExUnit.PhoenixState do
  def start(map), do: Agent.start_link fn -> map end, name: __MODULE__

  def get(key), do: Agent.get(__MODULE__, &Map.get(&1, key))
end
