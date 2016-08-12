defmodule Eecrit.AbilityGroup do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_superuser


  schema "ability_groups" do
    field :name, :string
    field :is_superuser, :boolean, default: false
    field :is_admin, :boolean, default: false

    timestamps()
  end

  # Fields the outside world is able to set. NOT necessarily the same
  # as the fields in the schema.
  @visible_fields [:name, :is_superuser, :is_admin]
  
  defp changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end
end
