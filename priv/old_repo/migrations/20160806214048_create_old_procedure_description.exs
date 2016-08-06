defmodule Eecrit.OldRepo.Migrations.CreateOldProcedureDescription do
  use Ecto.Migration

  def change do
    create table(:procedure_descriptions) do
      add :animal_kind, :text
      add :description, :text
      add :procedure_id, references(:procedures, on_delete: :nothing)
    end
    create index(:procedure_descriptions, [:procedure_id])

  end
end
