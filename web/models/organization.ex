defmodule Eecrit.Organization do
  use Eecrit.Web, :model

  # Fields the outside world is able to set. NOT necessarily the same
  # as the fields in the schema.
  @visible_fields [:short_name, :full_name]
  
  schema "organizations" do
    field :short_name, :string
    field :full_name, :string

    many_to_many :users, Eecrit.User, join_through: "users_organizations"

    timestamps()
  end

  defp changeset(starting_organization, updates) do
    starting_organization
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end

  def new_action_changeset do   # Start empty
    changeset(%Eecrit.Organization{}, %{})
  end

  def create_action_changeset(params) do
    changeset(%Eecrit.Organization{}, params)
  end

  def edit_action_changeset(organization) do
    changeset(organization, %{})
  end

  def update_action_changeset(organization, updates) do
    changeset(organization, updates)
  end
end
