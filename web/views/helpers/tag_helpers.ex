defmodule Eecrit.TagHelpers.Macros do
  defmacro tag_wrapper(tag) do
    quote do
      def unquote(tag)(content, params \\ []) do
        m_content_tag(unquote(tag), content, params)
      end
    end
  end
end


defmodule Eecrit.TagHelpers do
  use Phoenix.HTML
  import Eecrit.ControlFlow
  import Eecrit.TagHelpers.Macros
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

  def empty_content?(content) do
    # Enum.empty? won't work because top-level elements of an iolist can be chars.
    safe_empty? = &(&1 == [])
    safe_text? = &(is_tuple(&1) || is_binary(&1))
    cond do
      safe_empty?.(content) -> true
      safe_text?.(content) -> false
      Enum.all?(content, safe_empty?) -> true
      :else -> false
    end
  end

  def m_content_tag(tag, content, params \\ []) do
    list_unless empty_content?(content), do: content_tag(tag, content, params)
  end

  def m_surround_content(prefix, content, suffix) do
    list_unless empty_content?(content), do: [prefix, content, suffix]
  end

  def big_button(text, path) do
    link(text, to: path, class: "btn btn-primary btn-lg")
  end

  def m_resource_button(conn, text, model) do
    {current_user, path_fn} = correlates_of(conn, model)
    list_if can?(current_user, :work_with, model),
      do: big_button(text, resource_index_path(conn, path_fn))
  end

  def m_no_user_button(conn, text, path) do
    list_unless conn.assigns.current_user, do: big_button(text, path)
  end

  def m_resource_link(conn, text, model) do
    {current_user, path_fn} = correlates_of(conn, model)
    list_if can?(current_user, :work_with, model),
      do: link(text, to: resource_index_path(conn, path_fn))
  end
  def add_space(iolists) do
    list_unless empty_content?(iolists), do: Enum.intersperse(iolists, " ")
  end

  # TODO: should really build this from a list.
  tag_wrapper(:button)
  tag_wrapper(:div)
  tag_wrapper(:li)
  tag_wrapper(:p)
  tag_wrapper(:ul)
  tag_wrapper(:span)
  tag_wrapper(:nav)
  tag_wrapper(:a)


  def symbol_span(class), do: tag(:span, class: class)

  def resource_index_path(conn, path_builder) do
    apply(Eecrit.Router.Helpers, path_builder, [conn, :index])
  end

  defp correlates_of(conn, model),
    do: {conn.assigns.current_user, resource_path_maker(model)}

  defmacro __using__(_arg) do
    quote do
      import Eecrit.TagHelpers.Macros
      import Eecrit.TagHelpers
    end
  end
end
