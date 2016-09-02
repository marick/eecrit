defmodule Eecrit.OldAnimalSourceTest do
  use Eecrit.ModelCase
  alias Eecrit.OldAnimalSource

  def run(options),
    do: OldAnimalSource.all_ordered(options) |> Enum.map(&Map.get(&1, :name))
  
  def everything, do: run(include_out_of_service: true)
  def in_service, do: run(include_out_of_service: false)

  describe "all_ordered" do 
    test "returns human-style alphabetical ordering" do
      insert_old_animal(name: "ab")
      insert_old_animal(name: "AA")
      insert_old_animal(name: "Z")
      insert_old_animal(name: "m")
      insert_old_animal(name: "12")

      assert everything == ["12", "AA", "ab", "m", "Z"]

      # With this data, no difference between two ways of calling
      assert in_service == ["12", "AA", "ab", "m", "Z"]
    end

    test "does not return items that are out of service" do
      yesterday = Timex.shift(Timex.today, days: -1) |> Ecto.Date.cast!
      today = Timex.today |> Ecto.Date.cast!
      tomorrow = Timex.shift(Timex.today, days: 1) |> Ecto.Date.cast!

      insert_old_animal(name: "yesterday", date_removed_from_service: yesterday)
      insert_old_animal(name: "today", date_removed_from_service: today)
      insert_old_animal(name: "tomorrow", date_removed_from_service: tomorrow)

      # Note that animals are removed from service at the start of the day
      assert in_service == ["tomorrow"]

      # But everything can be returned
      assert everything == ["today", "tomorrow", "yesterday"]
    end      
  end
end
