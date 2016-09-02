defmodule Eecrit.OldProcedure do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_admin

  alias Eecrit.User
  alias Eecrit.Pile

  schema "procedures" do
    field :name, :string
    field :days_delay, :integer

    has_many :procedure_descriptions, Eecrit.OldProcedureDescription, foreign_key: :procedure_id
  end

  @visible_fields [:name, :days_delay]
  @fields_always_required @visible_fields

  defp changeset(struct, params) do
    struct
    |> cast(params, @visible_fields)
    |> validate_required(@fields_always_required)
  end


  ## Utility

  def alphabetical_names(procedure_list) do
    procedure_list
    |> Pile.sort_human_alphabetically(:name)
    |> Pile.fields(:name)
  end

end
