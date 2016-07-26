defmodule Eecrit.OldAnimalView do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers

  @out_of_service_marker %{"include_out_of_service" => "true"}

  defp page_description(@out_of_service_marker), do: "All animals"
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

  defp maybe_out_of_service_column(:head, @out_of_service_marker) do
    content_tag(:th, "Date removed from service")
  end

  defp maybe_out_of_service_column(old_animal, @out_of_service_marker) do
    content_tag(:td, old_animal.date_removed_from_service)
  end

  defp maybe_out_of_service_column(_, _), do: ""
end
