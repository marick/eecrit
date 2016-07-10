defmodule Eecrit.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :short_name,   :string,   null: false
      add :full_name,    :string,   null: false

      timestamps
    end
  end
end
