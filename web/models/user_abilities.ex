defmodule Eecrit.UserAbilities.Macros do
  defmacro requires(model, ability) do
      quote do
        def can?(%Eecrit.User{ability_group: %{unquote(ability) => val}},
                 _,
                unquote(model)), do: val
      end
    end
end

defmodule Eecrit.UserAbilities do
  alias Eecrit.User
  import Eecrit.UserAbilities.Macros
  
  defimpl Canada.Can, for: User do
    requires(Eecrit.OldAnimal, :is_admin)
    requires(Eecrit.OldProcedure, :is_admin)
    requires(Eecrit.OldProcedureDescription, :is_admin)
    
    def can?(%User{}, _, _), do: false
  end

  defimpl Canada.Can, for: Atom do
    def can?(_, _, _), do: false
  end
end
