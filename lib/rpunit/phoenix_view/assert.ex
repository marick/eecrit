defmodule RoundingPegs.ExUnit.PhoenixView.Assert.Macros do
  defp all_checker_names(action) do
    make_name = fn(prefix) -> "#{prefix}_#{action}!" |> String.to_atom end
    {make_name.("allows"), make_name.("disallows"), make_name.("disallows_any")}
  end

  defmacro make_anchor_checker(action) do
    {allows_name, disallows_name, _} = all_checker_names(action)

    quote do
      def unquote(allows_name)(html, path_shorthand) do 
        allows_anchor!(html, unquote(action), path_shorthand)
      end
      
      def unquote(allows_name)(html, path_shorthand, expecteds) do 
        allows_anchor!(html, unquote(action), path_shorthand, expecteds)
      end
      
      def unquote(disallows_name)(html, path_shorthand) do 
        disallows_anchor!(html, unquote(action), path_shorthand)
      end
    end
  end

  defmacro make_form_checker(action) do
    {allows_name, disallows_name, disallows_any_name} = all_checker_names(action)

    quote do
      def unquote(allows_name)(html, path_shorthand) do 
        allows_form!(html, unquote(action), path_shorthand)
      end
      
      def unquote(allows_name)(html, path_shorthand, expecteds) do 
        allows_form!(html, unquote(action), path_shorthand, expecteds)
      end
      
      def unquote(disallows_name)(html, path_shorthand) do 
        disallows_form!(html, unquote(action), path_shorthand)
      end

      def unquote(disallows_any_name)(html, path_shorthand) do 
        disallows_any_form!(html, unquote(action), path_shorthand)
      end
    end
  end
end

defmodule RoundingPegs.ExUnit.PhoenixView.Assert do
  import RoundingPegs.ExUnit.Macros
  import ExUnit.Assertions
  alias RoundingPegs.ExUnit.PhoenixView.PathMaker
  import RoundingPegs.ExUnit.PhoenixView.Assert.Macros
  require Floki

  @moduledoc """
  This module mostly contains checker-style assertions that are
  used to query views about links and forms generated from path helpers.
  """

  ### Anchors

  defp anchor_trees_with_source(html, action, path_shorthand) do 
    path = PathMaker.cast_to_path(action, path_shorthand)
    trees = Floki.find(html, "a[href='#{path}']")
    {trees, path, action}
  end
  
  defp some_anchor_trees!({trees, path, _action} = arg) do 
    if Enum.empty?(trees), do: flunk("Found no <a> matching #{pretty_path path}")
    arg
  end

  defp no_anchor_trees!({trees, path, action} = arg) do
    unless Enum.empty?(trees), do: flunk("Found disallowed #{pretty_action action} <a> to #{pretty_path path}")
    arg
  end

  defp can_extract_expected_text!({trees, path, action}, extract_fn, expected) do
    possible_texts = Enum.map(trees, extract_fn)
    matches = Enum.filter(possible_texts, &(&1 == expected))
    if Enum.empty?(matches) do
      msg =
        "No #{pretty_action action} for #{pretty_path path} has the correct text.\n" <>
        "Here are the incorrect texts:\n  " <>
        Enum.join(possible_texts, "\n  ")
      flunk(msg)
    end
  end


  # TODO: why can't these both be defcheckers?
  def allows_anchor!(html, action, path_shorthand) do
    anchor_trees_with_source(html, action, path_shorthand)
    |> some_anchor_trees!

    html
  end

  def allows_anchor!(html, action, path_shorthand, text: text) do
    anchor_trees_with_source(html, action, path_shorthand)
    |> some_anchor_trees!
    |> can_extract_expected_text!(&Floki.text/1, text)

    html
  end

  def allows_anchor!(_html, _action, _path_shorthand, args) do
    msg = if is_binary(args) do
      shorter = Curtail.truncate(args, length: 15)
      "The last argument should be a keyword list. Did you mean `text: #{inspect shorter}?`"
    else
      "Your final argument (#{inspect args}) is invalid."
    end
    raise msg
  end

  defchecker disallows_anchor!(html, action, path_shorthand) do
    anchor_trees_with_source(html, action, path_shorthand)
    |> no_anchor_trees!
  end

  ### Forms

  def has_true_rest_verb?(form_tree, desired_verb) do
    relevant_input = Floki.find(form_tree, "input[name='_method']")
    true_rest_verb =
      if Enum.empty?(relevant_input) do
        "post"
      else
        relevant_input |> Floki.attribute("value") |> List.first
      end
    true_rest_verb == desired_verb
  end

  defp action_to_rest_verb(action) do
    %{delete: "delete",
      create: "post",
      update: "put"}
    |> Map.get(action)
  end

  defp form_trees_by_action_and_path(html, action, path_css_selector,
                                     selection_type \\ "=") do
    html
    |> Floki.find("form[method='post']")
    |> Floki.find("form[action#{selection_type}'#{path_css_selector}']")
    |> Enum.filter(&(has_true_rest_verb?(&1, action_to_rest_verb(action))))
  end
  
  defp form_trees_with_source(html, action, path_shorthand) do 
    path = PathMaker.cast_to_path(action, path_shorthand)
    trees = form_trees_by_action_and_path(html, action, path)
    {trees, path, action}
  end

  defp some_form_trees!({trees, path, action} = arg) do 
    if Enum.empty?(trees), do: flunk("Found no #{pretty_action action} <form> matching #{pretty_path path}")
    arg
  end

  defp no_form_trees!({trees, path, action} = arg) do
    unless Enum.empty?(trees), do: flunk("Found disallowed #{pretty_action action} <form> for #{pretty_path path}")
    arg
  end

  def allows_form!(html, action, path_shorthand) do
    form_trees_with_source(html, action, path_shorthand)
    |> some_form_trees!

    html
  end

  def allows_form!(html, action, path_shorthand, text: text) do
    extracter = fn(trees) -> Floki.find(trees, "a") |> Floki.text end
    
    form_trees_with_source(html, action, path_shorthand)
    |> some_form_trees!
    |> can_extract_expected_text!(extracter, text)
    
    html
  end

  defchecker disallows_form!(html, action, path_shorthand) do
    form_trees_with_source(html, action, path_shorthand)
    |> no_form_trees!
  end

  
  defp minimal_path_for_form_action(path_shorthand) do
    canonicalized = PathMaker.canonicalize(path_shorthand)
    unless Enum.empty?(canonicalized.params),
      do: raise ArgumentError, message: "`disallows_any_form!` may not take parameters."
    unless Enum.empty?(canonicalized.args),
      do: raise ArgumentError, message: "`disallows_any_form!` must be a module name or zero-argument path function: no args allowed."
    PathMaker.cast_to_path(:create, canonicalized)
  end

  defchecker disallows_any_form!(html, action, path_shorthand) do
    path = minimal_path_for_form_action(path_shorthand)
    trees = form_trees_by_action_and_path(html, action, path, "^=")
    {trees, "#{path}...", action}
    |> no_form_trees!
  end

  # The specialized versions
  make_anchor_checker(:index)
  make_anchor_checker(:new)
  make_anchor_checker(:edit)
  make_anchor_checker(:show)
  
  make_form_checker(:delete)
  make_form_checker(:create)
  make_form_checker(:update)
  
  # Misc

  defp pretty_action(action), do: ":#{action}"
  defp pretty_path(path), do: path

  
end
