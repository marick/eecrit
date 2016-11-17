defmodule Eecrit.Animal do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  alias Eecrit.Animal

  @schema_prefix "demo"
  schema "animals" do
    field :name, :string
    field :date_acquired, Ecto.Date
    field :date_removed, Ecto.Date
    field :tags, {:array, :string}
    field :kvs, :map

    timestamps()
  end

  @visible_fields []    # You will want to change this
  @fields_always_required @visible_fields

  defp changeset(struct, params) do
    struct
    |> cast(params, @visible_fields)
    |> validate_required(@fields_always_required)
  end
end
