defmodule Eecrit.OldGroup do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_admin

  alias Eecrit.OldReservation
  alias Eecrit.OldUse

  schema "groups" do
    belongs_to :reservation, OldReservation
    has_many :uses, OldUse, foreign_key: :group_id
  end

  @visible_fields [:reservation_id]

  defp changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end
end

