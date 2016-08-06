defmodule Eecrit.OldProcedureDescription do
  use Eecrit.Web, :model

  schema "procedure_descriptions" do
    field :animal_kind, :string
    field :description, :string
    belongs_to :procedure, Eecrit.Procedure
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:animal_kind, :description])
    |> validate_required([:animal_kind, :description])
  end
end
