defmodule RoundingPegs.ExUnit.PhoenixView.Assert do
  import RoundingPegs.ExUnit.CheckStyle
  import ExUnit.Assertions
  alias RoundingPegs.ExUnit.PhoenixView.PathMaker
  require Floki

  @moduledoc """
  This module mostly contains checker-style assertions that are
  used to query views about links and forms generated from path helpers.
  They are generally used in this form:

    html
    |> allows_index!(Eecrit.Animal, "View all animals")
    |> disallows_update!(%Eecrit.Animal{...})
    |> allows_create!([Eecrit.Animal, 1])
    |> allows_create!([Eecrit.Animal, foo: 3])
  """

  ### Anchors

  defp anchor_trees_with_source(html, action, path_shorthand) do 
    path = PathMaker.cast_to_path(action, path_shorthand)
    trees = Floki.find(html, "a[href='#{path}']")
    {trees, path, action}
  end
  
  defp some_anchor_trees!({trees, path, _action} = arg) do 
    if Enum.empty?(trees), do: flunk("No <a> matching #{pretty_path path}")
    arg
  end

  def no_anchor_trees!({trees, path, action} = arg) do
    unless Enum.empty?(trees), do: flunk("Disallowed #{pretty_action action} <a> to #{pretty_path path}")
    arg
  end

  defp exactly_matching_anchor_text!({trees, path, action} = arg, expected) do
    matches = Enum.filter(trees, &(Floki.text(&1) == expected))
    if Enum.empty?(matches) do
      incorrects = Enum.map(trees, &Floki.text/1)
      msg =
        "No #{pretty_action action} <a> to #{pretty_path path} has the correct text.\n" <>
        "Here are the incorrect texts:\n  " <>
        Enum.join(incorrects, "\n  ")
      flunk(msg)
    end
    arg
  end

  # TODO: why can't these both be defcheckers?
  def allows_anchor!(html, action, path_shorthand) do
    anchor_trees_with_source(html, action, path_shorthand)
    |> some_anchor_trees!

    html
  end

  def allows_anchor!(html, action, path_shorthand, expected) when is_binary(expected) do
    anchor_trees_with_source(html, action, path_shorthand)
    |> some_anchor_trees!
    |> exactly_matching_anchor_text!(expected)

    html
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

  def action_to_rest_verb(action) do
    %{delete: "delete",
      create: "post",
      update: "put"}
    |> Map.get(action)
  end
  
  defp form_trees_with_source(html, action, path_shorthand) do 
    path = PathMaker.cast_to_path(action, path_shorthand)
    trees =
      html
      |> Floki.find("form[method='post']")
      |> Floki.find("form[action='#{path}']")
      |> Enum.filter(&(has_true_rest_verb?(&1, action_to_rest_verb(action))))
    {trees, path, action}
  end

  defp some_form_trees!({trees, path, action} = arg) do 
    if Enum.empty?(trees), do: flunk("No #{pretty_action action} <form> matching #{pretty_path path}")
    arg
  end

  def no_form_trees!({trees, path, action} = arg) do
    unless Enum.empty?(trees), do: flunk("Disallowed #{pretty_action action} <form> for #{pretty_path path}")
    arg
  end



  defchecker allows_form!(html, action, path_shorthand) do
    form_trees_with_source(html, action, path_shorthand)
    |> some_form_trees!
  end

  defchecker disallows_form!(html, action, path_shorthand) do
    form_trees_with_source(html, action, path_shorthand)
    |> no_form_trees!
  end

  
  # Misc

  defp pretty_action(action), do: ":#{action}"
  defp pretty_path(path), do: path
end
