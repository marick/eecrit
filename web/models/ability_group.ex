defmodule Eecrit.AbilityGroup do
  use Eecrit.Web, :model

  # Fields the outside world is able to set. NOT necessarily the same
  # as the fields in the schema.
  @visible_fields [:name, :is_superuser, :is_admin]
  
  schema "ability_groups" do
    field :name, :string
    field :is_superuser, :boolean, default: false
    field :is_admin, :boolean, default: false

    timestamps()
  end

  defp changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end

  def new_action_changeset do   # Start empty
    changeset(%Eecrit.AbilityGroup{}, %{})
  end

  def create_action_changeset(params) do
    changeset(%Eecrit.AbilityGroup{}, params)
  end

  def edit_action_changeset(ability_group) do
    changeset(ability_group, %{})
  end

  def update_action_changeset(ability_group, updates) do
    changeset(ability_group, updates)
  end
end
