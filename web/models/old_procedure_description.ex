defmodule Eecrit.OldProcedureDescription do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_admin

  @valid_animal_kinds ["any species" | Eecrit.OldAnimal.valid_species]
  def valid_animal_kinds, do: @valid_animal_kinds

  schema "procedure_descriptions" do
    field :animal_kind, :string
    field :description, :string
    belongs_to :procedure, Eecrit.OldProcedure
  end

  @form_fields [:animal_kind, :description, :procedure_id]
  @fields_always_required [:animal_kind, :procedure_id]

  defp changeset(struct, params) do
    struct
    |> cast(params, @form_fields)
    |> validate_required(@fields_always_required)
    |> validate_inclusion(:animal_kind, @valid_animal_kinds)
  end
end
