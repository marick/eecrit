defmodule Eecrit.Repo.Migrations.CreateAnimal do
  use Ecto.Migration

  def change do
    create table(:animals, prefix: :demo) do
      add :name, :string, null: false
      add :date_acquired, :date, null: false, default: fragment("CURRENT_DATE")
      add :date_removed, :date
      add :tags, {:array, :string}, null: false, default: []
      add :kvs, :map, null: false, default: fragment("'{}'::json")

      timestamps()
    end
  end
end
