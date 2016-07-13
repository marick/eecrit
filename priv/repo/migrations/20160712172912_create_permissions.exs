defmodule Eecrit.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :tag, :string

      add :in_all_organizations, :boolean, default: false, null: false
      add :can_add_users, :boolean, default: false, null: false
      add :can_see_admin_page, :boolean, default: false, null: false
      add :is_turned_off, :boolean, default: false, null: false
      
      timestamps()
    end

    create table(:user_permissions) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)
      add :permissions_id, references(:permissions, on_delete: :delete_all)
    end
    create unique_index(:user_permissions, [:user_id, :organization_id])
  end
end
