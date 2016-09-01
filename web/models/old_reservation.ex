defmodule Eecrit.OldReservation do 
  use Eecrit.Web, :model

  schema "reservations" do
    field :course, :string
    field :first_date, Ecto.Date
    field :last_date, Ecto.Date
    field :time_bits, :string
    field :note, :string
    has_many :groups, Eecrit.OldGroup, foreign_key: :reservation_id
    has_many :uses, through: [:groups, :uses]
    has_many :animals, through: [:groups, :uses, :animal]
    has_many :procedures, through: [:groups, :uses, :procedure]
  end

  def base_query do 
    from reservation in Eecrit.OldReservation,
      where: reservation.id in [10, 13, 17, 18, 20],
      join: animal in assoc(reservation, :animals),
      join: procedure in assoc(reservation, :procedures)
  end

  def restrict_to_date_range(query, start_date_inclusive, end_date_inclusive) do
    from [reservation] in query,
      where: fragment("(?, ? + interval '1 day') OVERLAPS (?, ? + interval '1 day')",
        reservation.first_date, reservation.last_date,
        type(^start_date_inclusive, :date),
        type(^end_date_inclusive, :date))
  end

  def select_animal_procedure_period(query) do
    from [reservation, animal, procedure] in query,
      select: {animal.name, procedure.name, reservation.first_date, reservation.last_date}
  end
    

  def procedures_per_animal(start_date_inclusive, end_date_inclusive) do
    base_query
    |> restrict_to_date_range(start_date_inclusive, end_date_inclusive)
    |> select_animal_procedure_period
    |> Eecrit.OldRepo.all
#    |> Enum.map(&(trim_dates(&1, {start_date_include
#    |> Enum.map(add_day_count)
  end
end

defmodule Eecrit.OldGroup do
  use Eecrit.Web, :model

  schema "groups" do
    belongs_to :reservation, Eecrit.OldReservation
    has_many :uses, Eecrit.OldUse, foreign_key: :group_id
  end
end

defmodule Eecrit.OldUse do
  use Eecrit.Web, :model

  schema "uses" do
    belongs_to :animal, Eecrit.OldAnimal
    belongs_to :procedure, Eecrit.OldProcedure
    belongs_to :group, Eecrit.OldGroup
  end
end

