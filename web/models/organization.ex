defmodule Eecrit.Organization do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__

  # Fields the outside world is able to set. NOT necessarily the same
  # as the fields in the schema.
  @visible_fields [:short_name, :full_name]
  
  schema "organizations" do
    field :short_name, :string
    field :full_name, :string

    many_to_many :users, Eecrit.User, join_through: "users_organizations"

    timestamps()
  end

  defp changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end
end
