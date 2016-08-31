defmodule Eecrit.OldRepo.Migrations.MoreOldRepoTables do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :course, :string
      add :time, :string
      add :first_date, :date
      add :last_date, :date
      add :time_bits, :string
      add :note, :text
    end

    create table(:groups) do
      add :reservation_id, references(:reservations)
    end

    create table(:uses) do
      add :group_id, references(:groups)
      add :animal_id, references(:animals)
      add :procedure_id, references(:procedures)
    end
  end
end
