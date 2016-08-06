defmodule Eecrit.OldRepo.Migrations.CreateOldProcedure do
  use Ecto.Migration

  def change do
    create table(:procedures) do
      add :name, :text
      add :days_delay, :integer
    end
  end
end
