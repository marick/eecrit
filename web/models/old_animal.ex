defmodule Eecrit.OldAnimal do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_admin

  use Timex
  alias Eecrit.Pile
  alias Eecrit.TimeUtil

  @valid_species ~w{bovine caprine equine}
  def valid_species, do: @valid_species

  schema "animals" do
    field :name, :string
    field :nickname, :string
    field :kind, :string
    field :procedure_description_kind, :string
    field :date_removed_from_service, Ecto.Date

    has_many :uses, Eecrit.OldUse, foreign_key: :animal_id
    has_many :reservations, through: [:uses, :group, :reservation]
  end

  @visible_fields [:name, :nickname, :kind, :procedure_description_kind, :date_removed_from_service]
  @fields_always_required [:name, :kind, :procedure_description_kind]

  defp changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@fields_always_required)
    |> validate_inclusion(:procedure_description_kind, @valid_species)
  end

  def already_out_of_service?(old_animal, today \\ Timex.today) do
    db_date = TimeUtil.cast_to_date!(old_animal.date_removed_from_service)
    not Timex.after?(db_date, today)
  end

  def alphabetical_names(animal_list) do
    animal_list
    |> Pile.sort_human_alphabetically(:name)
    |> Pile.extract_values(:name)
  end

  def flatten_condensed_reservations(reservations) do 
    for r <- reservations, a <- r.animals, p <- r.procedures, 
      do: {a, p, TimeUtil.days_covered(r.date_range)}
  end

  # I think I could do this better if I understood Access better
  def reduce_step({animal, procedure, use_count}, so_far) do
    cond do
      so_far[animal] == nil ->
        so_far |> Map.put(animal, %{}) |> put_in([animal, procedure], use_count)
      so_far[animal][procedure] == nil ->
        update_in(so_far, [animal], &(Map.put(&1, procedure, use_count)))
      :else ->
        update_in(so_far, [animal, procedure], &(&1 + use_count))
    end
  end

  def use_days(condensed_reservations) do
    flats = flatten_condensed_reservations(condensed_reservations)
    Enum.reduce(flats, %{}, &reduce_step/2)
  end      
end
