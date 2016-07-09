defmodule Eecrit.Repo.Migrations.CreateOrganization do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :short_name, :string
      add :full_name, :string

      timestamps()
    end

    create unique_index(:organizations, [:short_name])
  end
end
