defmodule Eecrit.V2Animal do

  defstruct version: 1, base: nil, deltas: []


  defmodule Base do
    defstruct id: nil,
      name: nil,
      species: nil,
      tags: [],
      int_properties: %{},
      bool_properties: %{},
      string_properties: %{},
      creation_date: nil
  end

  defmodule Delta do
    defstruct updated_at: nil,
      name_change: nil,
      tag_additions: [],
      tag_subtractions: []
  end

  def export(animal) do
    Map.put(animal.base, :version, animal.version)
  end

end
