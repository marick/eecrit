defmodule Eecrit.User do
  use Eecrit.Web, :model

  @postgres_string_max 255

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

  # By (my) convention, `changeset` creates a minimal changeset that
  # does nothing but filter out unwanted params. No fields are
  # required.
  defp changeset(struct, params) do 
    struct
    |> cast(params, [:display_name, :login_name, :password])
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

  def empty_creation_changeset do
    changeset(%Eecrit.User{}, %{})
  end
  
  def checking_creation_changeset(params) do
    empty_creation_changeset
    |> changeset(params)
    |> validate_required([:display_name, :login_name, :password])
    |> check_field_descriptions
    |> add_hashed_password
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
