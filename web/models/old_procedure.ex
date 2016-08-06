defmodule Eecrit.OldProcedure do
  use Eecrit.Web, :model

  schema "procedures" do
    field :name, :string
    field :days_delay, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :days_delay])
    |> validate_required([:name, :days_delay])
  end
end
