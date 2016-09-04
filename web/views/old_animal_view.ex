defmodule Eecrit.OldAnimalView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers
  alias Eecrit.OldAnimal
  alias Eecrit.TimeUtil

  @out_of_service_marker %{"include_out_of_service" => "true"}

  defp page_description(@out_of_service_marker), do: "All animals, past and present"
  defp page_description(_), do: "All animals currently in service"

  defp toggle_link(conn, @out_of_service_marker) do
    link "Don't show animals that are out of service", to: old_animal_path(conn, :index),
         class: "btn btn-default"
  end

  defp toggle_link(conn, _) do
    link("Include animals out of service",
      to: old_animal_path(conn, :index, include_out_of_service: true),
      class: "btn btn-default")
  end

  defp out_of_service_header(@out_of_service_marker) do
    "Date animal was or will be removed from service"
  end

  defp out_of_service_header(_) do
    "Date animal will be removed from service"
  end

  def out_of_service_description(animal = %{date_removed_from_service: nil}) do
    content_tag(:strong, "#{animal.name} is not scheduled to be removed from service")
  end
  
  def out_of_service_description(animal = %{date_removed_from_service: date}) do
    msg = if OldAnimal.already_out_of_service?(animal) do
      "#{animal.name} was removed from service on"
    else
      "#{animal.name} will be removed from service on"
    end
    strong_msg = content_tag(:strong, msg)
    formatted = Eecrit.TimeUtil.friendly_format(date)
    Phoenix.HTML.raw "#{safe_to_string strong_msg}: #{formatted}"
  end
end


