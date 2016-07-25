defmodule Eecrit.OldAnimal do
  use Eecrit.Web, :model

  schema "animals" do
    field :name, :string
    field :nickname, :string
    field :kind, :string
    field :procedure_description_kind, :string
    field :date_removed_from_service, Ecto.Date
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :nickname, :kind, :procedure_description_kind, :date_removed_from_service])
    |> validate_required([:name, :nickname, :kind, :procedure_description_kind, :date_removed_from_service])
  end
end
