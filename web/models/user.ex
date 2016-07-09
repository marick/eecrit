defmodule Eecrit.User do
  use Eecrit.Web, :model

  @default_string_max 50

  schema "users" do
    field :display_name, :string
    field :login_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps
  end

  def changeset(starting_value, additions \\ :invalid) do
    starting_value
    |> cast(additions, ~w(display_name login_name), [])
    |> validate_length(:display_name, min: 1, max: @default_string_max)
    |> validate_length(:login_name, min: 7, max: @default_string_max)
    |> unique_constraint(:login_name)
  end

  def password_setting_changeset(starting_value, additions) do
    starting_value
    |> changeset(additions)
    |> cast(additions, ~w(password), [])
    |> validate_length(:password, min: 6)
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
