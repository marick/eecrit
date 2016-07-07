defmodule Eecrit.User do
  use Eecrit.Web, :model

  schema "users" do
    field :display_name, :string
    field :login_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :organizational_scope, :string

    timestamps
  end
end
