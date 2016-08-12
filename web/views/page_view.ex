defmodule Eecrit.PageView do
  use Eecrit.Web, :view
  use Eecrit.WebAssembly
  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure
  alias Eecrit.User
  alias Eecrit.Organization
  alias Eecrit.AbilityGroup
  import Eecrit.TagHelpers

  def commands(conn, current_user) do
    raw_builder do
      unless current_user do
        big_button_iolist("Please log in", session_path(conn, :new))
        |> wrap_in_section
      end

      section_of_resource_commands(conn, current_user,
        [{"Work With Animals", :old_animal_path, OldAnimal},
         {"Work With Procedures", :old_procedure_path, OldProcedure}])

      section_of_resource_commands(conn, current_user, 
        [{"Users", :user_path, User},
         {"Organizations", :organization_path, Organization},
         {"Ability Groups", :ability_group_path, AbilityGroup}])
    end
  end

  def section_of_resource_commands(conn, current_user, possibilities) do
    possibilities
    |> filter_by_resource_ability(current_user)
    |> build_commands(conn)
    |> wrap_in_section
  end

  defp filter_by_resource_ability(tuples, current_user) do
    Enum.filter(tuples, fn {_, _, resource} ->
      can?(current_user, :work_with, resource)
    end)
  end

  def wrap_in_section(iolists) when is_list(iolists) and length(iolists) == 0, do: nil
  def wrap_in_section(iolists) when is_list(iolists) do
    hr
    p [class: "lead"] do
      for iolist <- iolists, do: text(iolist)
    end
  end

  defp build_commands(tuples, conn) do
    for {text, path_builder, _} <- tuples do 
      big_button_iolist(text, resource_path(conn, path_builder))
    end
  end

  defp resource_path(conn, path_builder) do
    apply(Eecrit.Router.Helpers, path_builder, [conn, :index])
  end
end
