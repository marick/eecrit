defmodule Eecrit.WebAssembly do
  defmacro raw_builder(do: block) do
    quote do
      result = builder do
        unquote(block)
      end
      raw(result)
    end
  end

  defmacro __using__(_arg) do
    quote do 
      use WebAssembly
      import Eecrit.WebAssembly
    end
  end
end
