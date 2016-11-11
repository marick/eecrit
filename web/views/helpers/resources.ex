defmodule Eecrit.Helpers.Resources do
  use Phoenix.HTML
  import Eecrit.Helpers.Tags.Basics
  import Eecrit.Helpers.Tags.Macros
  import Canada.Can, only: [can?: 3]

  # TODO: Investigate if this table can be generated automatically.
  @resource_paths %{
    Eecrit.OldProcedure => :old_procedure_path,
    Eecrit.OldProcedureDescription => :old_procedure_description_path,
    Eecrit.OldAnimal => :old_animal_path,
    Eecrit.User => :user_path,
    Eecrit.Organization => :organization_path,
    Eecrit.AbilityGroup => :ability_group_path,
  }

  def resource_path_maker(model) do 
    Map.get(@resource_paths, model, "Eecrit.TagHelpers doesn't have a path registered for #{inspect model}")
  end

  def m_resource_link(conn, text, model) do
    {current_user, path_fn} = correlates_of(conn, model)
    build_if can?(current_user, :work_with, model),
      do: link(text, to: resource_index_path(conn, path_fn))
  end

  def resource_index_path(conn, path_builder) do
    apply(Eecrit.Router.Helpers, path_builder, [conn, :index])
  end

  defp correlates_of(conn, model),
    do: {conn.assigns.current_user, resource_path_maker(model)}
end
