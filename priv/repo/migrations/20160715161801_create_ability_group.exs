defmodule Eecrit.Repo.Migrations.CreateAbilityGroup do
  use Ecto.Migration

  def change do
    create table(:ability_groups) do
      add :name, :string
      add :is_superuser, :boolean, default: false, null: false
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

    create table(:ability_group_chooser) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :organization_id, references(:organizations, on_delete: :delete_all)
      add :ability_group_id, references(:ability_groups, on_delete: :delete_all)
    end
    create unique_index(:ability_group_chooser, [:user_id, :organization_id])
  end
end
