defmodule RoundingPegs.ExUnit.Assertions do
  import ExUnit.Assertions
  
  defmacro assert_exception(r, do: body) do
    quote do
      unquote(__MODULE__)._assert_exception(unquote(r), fn -> unquote(body) end)
    end
  end

  defmacro matches!(actual, expected) do
    quote do
      # Seems like you can't bind_quote just `actual`
      actual = unquote(actual)
      ExUnit.Assertions.assert(actual =~ unquote(expected))
      actual
    end
  end


  # private

  def _assert_exception(requirements, f) when is_list(requirements) do
    try do
      f.()
    rescue
      error -> assert_requirements(error, requirements)
    else
      _ -> flunk "Expected an exception, but none was thrown."
    end
  end
  def _assert_exception(requirement, f), do: _assert_exception([requirement], f)

  defp assert_requirements(error, requirements) do
    for r <- requirements, do: assert_requirement(error, r)
  end

  defp assert_requirement(error, requirement) when is_atom(requirement) do 
    stacktrace = System.stacktrace
    name = error.__struct__
    unless name == requirement do
      reraise ExUnit.AssertionError,
        [message: "Expected exception #{inspect requirement} but got #{inspect name} (#{Exception.message(error)})"],
        stacktrace
    end
  end

  defp assert_requirement(error, requirement) do
    msg = String.strip(Exception.message(error))
    assert msg =~ requirement
  end
  
end
