defmodule Eecrit.UserAbilities do
  alias Eecrit.User

  # TODO: Authorization is just modeled all wrong.
  defimpl Canada.Can, for: User do
    def can?(user = %User{}, :work_with, :reports),
      do: Map.get(user.ability_group, :is_admin)

    def can?(user = %User{}, :work_with, module) when is_atom(module) do
      needed_ability = apply(module, :required_ability, [])
      Map.get(user.ability_group, needed_ability)
    end

    def can?(%User{}, _, _), do: false
  end

  defimpl Canada.Can, for: Atom do
    def can?(_, _, _), do: false
  end
end
