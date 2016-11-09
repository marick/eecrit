defmodule Eecrit.OldAnimalApiView do
  use Eecrit.Web, :view

  def render("index.json", %{old_animals: old_animals}) do
    data =
      old_animals
      |> Enum.map(&(Map.take(&1, [:name, :kind])))
      |> sort_animals
    %{data: data}
  end

  def render("show.json", %{old_animal: old_animal}) do
    %{data: render_one(old_animal, Eecrit.OldAnimalApiView, "old_animal_api.json")}
  end

  def render("old_animal_api.json", %{old_animal: old_animal}) do
    IO.puts "old_animal: #{old_animal.name}"
    Map.take(old_animal, [:name, :kind])
  end

  defp sort_animals(animals) do
    sorter = fn(a1, a2) -> String.downcase(a1.name) < String.downcase(a2.name) end
    Enum.sort(animals, sorter)
  end
end
