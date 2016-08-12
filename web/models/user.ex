defmodule Eecrit.User do
  use Eecrit.Web, :model
  use Eecrit.ModelDefaults, model: __MODULE__
  resource_requires_ability :is_superuser

  @postgres_string_max 255
  @visible_fields [:display_name, :login_name, :password]
  
  schema "users" do
    field :display_name, :string
    field :login_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    # The following is really virtual, I guess, but I don't know the
    # right way to express it. It's currently attached to the User via
    # an independent lookup, (not `preload`) because the "primary key"
    # of AbilityGroupChooser is a {userid, organizationid} pair.
    has_one :ability_group, Eecrit.AbilityGroup
    belongs_to :current_organization, Eecrit.Organization
    many_to_many :organizations, Eecrit.Organization, join_through: "users_organizations"

    timestamps
  end

  defp changeset(base_struct, updates) do
    base_struct
    |> cast(updates, @visible_fields)
    |> validate_required(@visible_fields)
  end
  
  # By (my) convention, `check_field_descriptions` bundles all the
  # validations and constraints *other than* `validate_required`. That
  # is: these are the checks that are done if a field is present.
  defp check_field_descriptions(changeset) do
    changeset
    |> validate_length(:display_name, max: @postgres_string_max)
    |> validate_length(:login_name, max: @postgres_string_max)
    |> validate_length(:password, min: 6)
    |> unique_constraint(:login_name)
    |> assoc_constraint(:current_organization)
  end

  def create_action_changeset(params) do
    changeset(%Eecrit.User{}, params)
    |> check_field_descriptions()
    |> add_hashed_password()
  end

  def update_action_changeset(ability_group, updates) do
    changeset(ability_group, updates)
    |> check_field_descriptions()
    |> add_hashed_password()
  end

  def add_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true,
                     changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
