defmodule Eecrit.Repo.Migrations.AssociateUsersAndOrganizations do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :current_organization_id, references(:organizations, on_delete: :nilify_all)
    end

    create table(:users_organizations, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)
    end

    create unique_index(:users_organizations, [:user_id])
  end
end
