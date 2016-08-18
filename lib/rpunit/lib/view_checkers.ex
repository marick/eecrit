defmodule RoundingPegs.ExUnit.ViewCheckers.Util do
  import ExUnit.Assertions
  require Phoenix.ConnTest
  require ShouldI
  alias Eecrit.TagHelpers

  # Used for path generation
  @endpoint Eecrit.Endpoint

  def find_anchor(html, {link_text, link_path}) do
    html
    |> Floki.find("a[href='#{link_path}']")
    |> Enum.filter(&(Floki.text(&1) == link_text))
  end

  def path_to(model, action, nil, params), do: path_to(model, action, [], params)

  def path_to(model, action, arglist, params) when is_list(arglist) do
    path_maker = TagHelpers.resource_path_maker(model)
    arglist = [@endpoint, action] ++ arglist ++ [params]
    apply(Eecrit.Router.Helpers, path_maker, arglist)
  end

  def path_to(model, action, arg, params), 
    do: path_to(model, action, [arg], params)

  def pretty_action(action), do: ":#{action}"
  def pretty_path(path), do: path
  def pretty_text(text), do: inspect text

  def allows_anchor_x!(html, {link_text, model}, action, arg_or_arglist, params) do 
    link_path = path_to(model, action, arg_or_arglist, params)
    result = find_anchor(html, {link_text, link_path})
    refute result == [], "No #{pretty_action action} link to #{pretty_path link_path} and #{pretty_text link_text} in\n#{html}"
    html
  end

  def disallows_anchor_x!(html, model, action, arg_or_arglist, params) do
    link_path = path_to(model, action, arg_or_arglist, params)
    result = Floki.find(html, "a[href='#{link_path}']")
    assert result == [], "Observe the #{pretty_action action} link to #{pretty_path link_path} in\n#{html}"
    html
  end

  defp check_names(action) do
    make_name = fn(prefix) -> "#{prefix}_#{action}!" |> String.to_atom end
    {make_name.("allows"), make_name.("disallows"), make_name.("disallows_any")}
  end

  defmacro make_anchor_check(action) do
    {allows_name, disallows_name, _} = check_names(action)

    quote do
      def unquote(allows_name)(html, selector, arg_or_arglist \\ [], params \\ []) do 
        allows_anchor_x!(html, selector, unquote(action), arg_or_arglist, params)
      end
      
      def unquote(disallows_name)(html, model, arg_or_arglist \\ [], params \\ []) do 
        disallows_anchor_x!(html, model, unquote(action), arg_or_arglist, params)
      end
    end
  end

  def true_rest_verb(form_tree) do
    relevant_input = Floki.find(form_tree, "input[name='_method']")
    if Enum.empty?(relevant_input) do
      "post"
    else
      relevant_input |> Floki.attribute("value") |> List.first
    end
  end

  @actions_to_methods %{
    delete: "delete",
    create: "post",
    update: "put"
  }
  
  def find_form(html, link_path, action) do
    html
    |> Floki.find("form[method='post']")
    |> Floki.find("form[action='#{link_path}']")
    |> Enum.filter(&(true_rest_verb(&1) == Map.get(@actions_to_methods, action)))
  end

  def allows_form_x!(html, model, action, arg_or_arglist, params) do 
    link_path = path_to(model, action, arg_or_arglist, params)
    result = find_form(html, link_path, action)
    refute result == [], "No #{pretty_action action} form for #{pretty_path link_path} in\n#{html}"
    html
  end

  def disallows_form_x!(html, model, action, arg_or_arglist, params) do
    link_path = path_to(model, action, arg_or_arglist, params)
    result = find_form(html, link_path, action)
    assert result == [], "Observe the #{pretty_action action} form for #{pretty_path link_path} in\n#{html}"
    html
  end

  def disallows_any_form_x!(html, model, action) do
    link_path = path_to(model, :create, [], [])
    result = find_form(html, "^" <> link_path, action)
    assert result == [], "Observe the #{pretty_action action} form for #{pretty_path link_path} in\n#{html}"
    html
  end

  defmacro make_form_check(action) do
    {allows_name, disallows_name, disallows_any_name} = check_names(action)

    quote do
      def unquote(allows_name)(html, selector, arg_or_arglist \\ [], params \\ []) do 
        allows_form_x!(html, selector, unquote(action), arg_or_arglist, params)
      end
      
      def unquote(disallows_name)(html, model, arg_or_arglist \\ [], params \\ []) do 
        disallows_form_x!(html, model, unquote(action), arg_or_arglist, params)
      end

      def unquote(disallows_any_name)(html, model) do 
        disallows_any_form_x!(html, model, unquote(action))
      end
    end
  end
end

defmodule RoundingPegs.ExUnit.ViewCheckers do 
  import ExUnit.Assertions
  require Phoenix.ConnTest
  require ShouldI
  alias Eecrit.TagHelpers
  import RoundingPegs.ExUnit.ViewCheckers.Util

  # Used for path generation
  @endpoint Eecrit.Endpoint

  make_anchor_check(:index)
  make_anchor_check(:new)
  make_anchor_check(:edit)
  make_anchor_check(:show)

  make_form_check(:delete)
  make_form_check(:create)
  make_form_check(:update)
end

