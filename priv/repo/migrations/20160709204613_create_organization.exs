defmodule Eecrit.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :full_name, :string

      timestamps()
    end

  end
end
