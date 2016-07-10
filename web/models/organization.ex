defmodule Eecrit.Organization do
  use Eecrit.Web, :model

  schema "organizations" do
    field :short_name, :string
    field :full_name, :string

    many_to_many :users, Eecrit.User, join_through: "users_organizations"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:full_name, :short_name])
    |> validate_required([:full_name])
    |> validate_required([:short_name])
  end
end
