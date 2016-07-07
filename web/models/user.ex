defmodule Eecrit.User do
  use Eecrit.Web, :model

  @default_string_max 50

  schema "users" do
    field :display_name, :string
    field :login_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :organizational_scope, :string

    timestamps
  end

  def changeset(starting_value, additions \\ :invalid) do
    starting_value
    |> cast(additions, ~w(display_name login_name organizational_scope), [])
    |> validate_length(:display_name, min: 1, max: @default_string_max)
    |> validate_length(:login_name, min: 7, max: @default_string_max)
    |> validate_length(:organizational_scope, min: 1, max: @default_string_max)
    |> unique_constraint(:login_name)
  end
end
