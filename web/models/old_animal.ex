defmodule Eecrit.OldAnimal do
  use Eecrit.Web, :model

  schema "animals" do
    field :name, :string
    field :nickname, :string
    field :kind, :string
    field :procedure_description_kind, :string
    field :date_removed_from_service, Ecto.Date
  end

  @visible_fields [:name, :nickname, :kind, :procedure_description_kind, :date_removed_from_service]
  @fields_always_required [:name, :kind, :procedure_description_kind]

  ### TODO: Make this private 
  def changeset(base_struct, updates \\ %{}) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@fields_always_required)
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
  
end
