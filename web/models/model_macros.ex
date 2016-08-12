defmodule Eecrit.ModelMacros do 
  defmacro resource_requires_ability(ability) do
    quote do
      def required_ability, do: unquote(ability)
    end
  end
end
