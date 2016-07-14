defmodule Eecrit.Permissions do
  use Eecrit.Web, :model

  schema "permissions" do
    field :tag, :string
    field :in_all_organizations, :boolean, default: false
    field :can_add_users, :boolean, default: false
    field :can_see_admin_page, :boolean, default: false

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:tag, :in_all_organizations, :can_add_users, :can_see_admin_page])
    |> validate_required([:tag, :in_all_organizations, :can_add_users, :can_see_admin_page])
  end

  def fresh_changeset(params) do
    %Eecrit.Permissions{} |> changeset(params)
  end
end
