defmodule Eecrit.OldProcedureDescription do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__

  schema "procedure_descriptions" do
    field :animal_kind, :string
    field :description, :string
    belongs_to :procedure, Eecrit.Procedure
  end

  @visible_fields [:animal_kind, :description]
  @fields_always_required [:animal_kind]

  defp changeset(struct, params) do
    struct
    |> cast(params, @visible_fields)
    |> validate_required(@fields_always_required)
  end
end
