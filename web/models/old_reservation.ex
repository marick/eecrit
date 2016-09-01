defmodule Eecrit.OldReservation do 
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_admin

  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure
  alias Eecrit.OldGroup
  alias Eecrit.OldUse

  # TODO: Not all fields are included yet
  schema "reservations" do
    field :course, :string
    field :first_date, Ecto.Date
    field :last_date, Ecto.Date
    has_many :groups, Eecrit.OldGroup, foreign_key: :reservation_id
    has_many :uses, through: [:groups, :uses]
    has_many :animals, through: [:groups, :uses, :animal]
    has_many :procedures, through: [:groups, :uses, :procedure]
  end

  @visible_fields [:course, :first_date, :last_date]
  @required_fields @visible_fields

  defp changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end

  def insert_new!(reservation_fields, animals, procedures) do
    uses = for a <- animals, p <- procedures, do: %OldUse{animal: a, procedure: p}
    only_group = %OldGroup{uses: uses}
    reservation = %{reservation_fields | groups: [only_group]}
    Eecrit.OldRepo.insert!(reservation)
  end
end

