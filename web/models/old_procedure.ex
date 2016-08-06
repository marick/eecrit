defmodule Eecrit.OldProcedure do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  alias Eecrit.User

  schema "procedures" do
    field :name, :string
    field :days_delay, :integer
  end

  @visible_fields [:name, :days_delay]
  @fields_always_required @visible_fields

  defp changeset(struct, params) do
    struct
    |> cast(params, @visible_fields)
    |> validate_required(@fields_always_required)
  end

  defimpl Canada.Can, for: __MODULE__ do
    def can?(nil, _, _), do: false
    def can?(user = %User{}, _, _), do: user.ability_group.is_admin
  end
end
