defmodule Eecrit.Helpers.Tags.Macros do
  defmacro build_if(test, do: body) do
    quote do
      if unquote(test) do
        unquote(body)
      else
        []
      end
    end
  end

  # Don't *think* there's a way to use a just-defined macro in another one.
  defmacro build_unless(test, do: body) do
    quote do
      if !unquote(test) do
        unquote(body)
      else
        []
      end
    end
  end

  defmacro tag_maker(tag, function_name \\ nil) do
    function_name = function_name || tag
    maybe_function_name = "m_" <> Atom.to_string(function_name) |> String.to_atom
    quote do
      def unquote(function_name)(content, params \\ []) do
        content_tag(unquote(tag), content, params)
      end
      def unquote(maybe_function_name)(content, params \\ []) do
        maybe_content_tag(unquote(tag), content, params)
      end
    end
  end
end

defmodule Eecrit.Helpers.Tags.Basics do
  import Eecrit.Helpers.Tags.Macros
  import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3]

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

  def maybe_content_tag(tag, content, params \\ []) do
    build_unless empty_content?(content), do: content_tag(tag, content, params)
  end
end


defmodule Eecrit.Helpers.Tags do
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


  def m_surround_content(prefix, content, suffix) do
    build_unless empty_content?(content), do: [prefix, content, suffix]
  end

  def m_resource_link(conn, text, model) do
    {current_user, path_fn} = correlates_of(conn, model)
    build_if can?(current_user, :work_with, model),
      do: link(text, to: resource_index_path(conn, path_fn))
  end
  def add_space(iolists) do
    build_unless empty_content?(iolists), do: Enum.intersperse(iolists, " ")
  end

  # TODO: should really build this from a list.
  tag_maker(:button_tag)
  tag_maker(:div, :div_tag)
  tag_maker(:li)
  tag_maker(:p)
  tag_maker(:ul)
  tag_maker(:span)
  tag_maker(:nav)
  tag_maker(:a)


  def symbol_span(class), do: tag(:span, class: class)

  def resource_index_path(conn, path_builder) do
    apply(Eecrit.Router.Helpers, path_builder, [conn, :index])
  end

  defp correlates_of(conn, model),
    do: {conn.assigns.current_user, resource_path_maker(model)}

  defmacro __using__(_arg) do
    quote do
      import Eecrit.Helpers.Tags.Macros
      import Eecrit.Helpers.Tags.Basics
      import Eecrit.Helpers.Tags
    end
  end
end
