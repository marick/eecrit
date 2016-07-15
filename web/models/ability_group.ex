defmodule Eecrit.AbilityGroup do
  use Eecrit.Web, :model

  schema "ability_groups" do
    field :name, :string
    field :is_superuser, :boolean, default: false
    field :is_admin, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :is_superuser, :is_admin])
    |> validate_required([:name, :is_superuser, :is_admin])
  end
end
