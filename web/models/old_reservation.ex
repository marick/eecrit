defmodule Eecrit.OldReservation do 
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_admin

  alias Eecrit.OldGroup

  # TODO: Not all fields are included yet
  schema "reservations" do
    field :course, :string
    field :instructor, :string
    field :first_date, Ecto.Date
    field :last_date, Ecto.Date
    field :time_bits, :string
    field :note, :string
    has_many :groups, OldGroup, foreign_key: :reservation_id
    has_many :uses, through: [:groups, :uses]
    has_many :animals, through: [:groups, :uses, :animal]
    has_many :procedures, through: [:groups, :uses, :procedure]
  end

  @visible_fields [:course, :first_date, :last_date, :time_bits]
  @required_fields @visible_fields

  def changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end
end

