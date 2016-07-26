defmodule Eecrit.OldRepo.Migrations.AddOldAnimalsTable do
  use Ecto.Migration

  def change do
    create table(:animals) do
      add :name, :string
      add :nickname, :string
      add :kind, :string
      add :procedure_description_kind, :string
      add :date_removed_from_service, :date
    end
  end
end
