defmodule Eecrit.V2AnimalData do
  alias Eecrit.VersionedAnimal
  alias Eecrit.VersionedAnimal.Snapshot, as: Snapshot
  use Timex

  def early_date, do:         ~D[2015-03-01]
  def early_middle_date, do:  ~D[2016-03-01]
  def middle_date, do:        ~D[2017-03-01]
  def middle_latest_date, do: ~D[2018-03-01]
  def latest_date, do:        ~D[2019-03-01]

  def animal_params(overrides \\ %{}) do
    default = %{"id" => "ignored",
                "version" => "ignored",
                "name" => "new animal", 
                "species" => "equine", 
                "tags" => [ "stallion", "aggressive" ],
                "int_properties" => %{"val" => [1, "x"]},
                "bool_properties" => %{"Available" => [true, ""]},
                "string_properties" =>  %{ "Primary billing" => ["Marick", ""]},
                "creation_date" => middle_date
               }
    Enum.into(overrides, default)
  end

  def snapshot(overrides \\ []) do
    Enum.reduce(overrides,
      Snapshot.new(animal_params()),
      fn({k, v}, snapshot) -> Map.put(snapshot, k, v) end)
  end
end
