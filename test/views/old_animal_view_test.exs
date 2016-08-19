defmodule Eecrit.OldAnimalViewTest do
  use Eecrit.ViewCase, async: true
  alias Eecrit.OldAnimalView
  alias Eecrit.OldAnimal


  describe ":index has two cases: show animals out of service, or just those in service." do 
    
    test "only-in-service has affects on the view", %{conn: conn}  do
      html = render_to_string(OldAnimalView, "index.html",
        conn: conn, animals: [], params: %{})
      assert html =~ "All animals currently in service"
      allows_index!(html, {"Include animals out of service", OldAnimal}, [], include_out_of_service: true)
      # Has appropriate text in removal-from-service column
      assert html =~ "Date animal will be removed from service"
    end
    
    test "... as does showing out of service animals", %{conn: conn}  do
      html = render_to_string(OldAnimalView, "index.html",
        conn: conn, animals: [], params: %{"include_out_of_service" => "true"})
      assert html =~ "All animals, past and present"
      allows_index!(html, {"Don't show animals that are out of service", OldAnimal})
      assert html =~ "Date animal was or will be removed from service"
    end
  end

  describe "the variant descriptions of when the animal was removed" do
    setup %{removal_date: date_string} = context do
      date_arg = date_string && Ecto.Date.cast!(date_string)
      animal = make_old_animal(name: "Betsy", date_removed_from_service: date_arg)
      html = OldAnimalView.out_of_service_description(animal) |> to_view_string
      assign context, html: html
    end

    @tag removal_date: "2012-03-05" # long ago
    test "displaying when the animal was removed from service", %{html: html} do
      assert html =~ "Betsy was removed from service on"
      assert html =~ "March 5, 2012"
    end

    @tag removal_date: "2092-03-05" # far future
    test "displaying when the animal will be removed from service", %{html: html} do
      assert html =~ "Betsy will be removed from service on"
      assert html =~ "March 5, 2092"
    end

    @tag removal_date: nil  # none
    test "displaying when the animal has no removal date", %{html: html} do
      assert html =~ "Betsy is not scheduled to be removed from service"
    end
  end
end
