defmodule Eecrit.OldUse do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_admin

  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure
  alias Eecrit.OldGroup

  schema "uses" do
    belongs_to :animal, OldAnimal
    belongs_to :procedure, OldProcedure
    belongs_to :group, OldGroup
  end

  @visible_fields [:animal_id, :procedure_id, :group_id]

  defp changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end
end

