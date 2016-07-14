defmodule Eecrit.Permissions do
  use Eecrit.Web, :model

  schema "permissions" do
    field :tag, :string
    field :is_superuser, :boolean, default: false
    field :is_admin, :boolean, default: false

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:tag, :is_superuser, :is_admin])
    |> validate_required([:tag, :is_superuser, :is_admin])
  end

  def fresh_changeset(params) do
    %Eecrit.Permissions{} |> changeset(params)
  end
end
