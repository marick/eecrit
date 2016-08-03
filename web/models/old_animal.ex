defmodule Eecrit.OldAnimal do
  use Eecrit.Web, :model
  use Timex
  alias Eecrit.TimeUtil

  @valid_species ~w{bovine caprine equine}
  def valid_species, do: @valid_species


  schema "animals" do
    field :name, :string
    field :nickname, :string
    field :kind, :string
    field :procedure_description_kind, :string
    field :date_removed_from_service, Ecto.Date
  end

  @visible_fields [:name, :nickname, :kind, :procedure_description_kind, :date_removed_from_service]
  @fields_always_required [:name, :kind, :procedure_description_kind]

  defp changeset(base_struct, updates \\ %{}) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@fields_always_required)
    |> validate_inclusion(:procedure_description_kind, @valid_species)
  end

  def new_action_changeset do   # Start empty
    changeset(%Eecrit.OldAnimal{}, %{})
  end

  def create_action_changeset(params) do
    changeset(%Eecrit.OldAnimal{}, params)
  end

  def edit_action_changeset(old_animal) do
    changeset(old_animal, %{})
  end

  def update_action_changeset(old_animal, updates) do
    changeset(old_animal, updates)
  end


  def already_out_of_service?(old_animal, today \\ Timex.today) do
    db_date = TimeUtil.ecto_date_to_date(old_animal.date_removed_from_service)
    not Timex.after?(db_date, today)
  end
  
end
