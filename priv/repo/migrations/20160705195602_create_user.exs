defmodule Eecrit.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :display_name, :string
      add :login_name, :string, null: false
      add :password_hash, :string

      timestamps
    end

    create unique_index(:users, [:login_name])
  end
end
