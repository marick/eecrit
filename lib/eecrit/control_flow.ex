defmodule Eecrit.ControlFlow do
  defmacro list_if(test, do: body) do
    quote do
      if unquote(test) do
        unquote(body)
      else
        []
      end
    end
  end

  # Don't *think* there's a way to use a just-defined macro in another one.
  defmacro list_unless(test, do: body) do
    quote do
      if !unquote(test) do
        unquote(body)
      else
        []
      end
    end
  end

  defmacro list_augment_if(test, so_far, do: body) do
    quote do  # Note: Can't use bind_quoted because it would eval the body.
      so_far = unquote(so_far)
      if unquote(test) do
        [ unquote(body) | so_far ]
      else
        so_far
      end
    end
  end
end

