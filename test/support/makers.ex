defmodule Eecrit.Test.Makers do
  alias Eecrit.Repo
  alias Eecrit.OldRepo
  alias Eecrit.User
  alias Eecrit.Organization
  alias Eecrit.OldReservation
  alias Eecrit.OldAnimal
  alias Eecrit.OldProcedure
  alias Eecrit.OldProcedureDescription
  alias Eecrit.AbilityGroup

  # TODO: simplify this with macros or higher-level functions

  defp next_id do
    :random.uniform(1_000_000_000)
  end

  ## Ability Groups
  def make_ability_group("superuser") do
    %AbilityGroup{id: next_id, name: "superuser", is_superuser: true, is_admin: true}
  end

  def make_ability_group("admin") do 
    %AbilityGroup{id: next_id, name: "admin", is_superuser: false, is_admin: true}
  end

  def make_ability_group("user") do 
    %AbilityGroup{id: next_id, name: "user", is_superuser: false, is_admin: false}
  end

  def insert_ability_group(overrides \\ %{}) do
    defaults = %{id: next_id, name: "org name",
                 is_superuser: true, is_admin: false}
    struct(AbilityGroup, Dict.merge(defaults, overrides))
    |> AbilityGroup.edit_action_changeset()
    |> Repo.insert!()
  end

  ## Old animals
  def make_old_animal(overrides \\ %{}) do
    defaults = %{id: next_id,
                 name: "Hayley",
                 kind: "gelding",
                 procedure_description_kind: "equine",
                 date_removed_from_service: nil}
    struct(OldAnimal, Dict.merge(defaults, overrides))
  end

  def insert_old_animal(overrides \\ %{}) do
    make_old_animal(overrides)
    |> OldAnimal.edit_action_changeset()
    |> OldRepo.insert!()
  end


  ## Old Procedures
  def make_old_procedure(overrides \\ %{}) do
    defaults = %{id: next_id,
                 name: "Bandage demonstration",
                 days_delay: 0}
    
    struct(OldProcedure, Dict.merge(defaults, overrides))
  end

  def insert_old_procedure(overrides \\ %{}) do
    make_old_procedure(overrides)
    |> OldProcedure.edit_action_changeset()
    |> OldRepo.insert!()
  end

  ## Old Procedure Descriptions
  def make_old_procedure_description(overrides \\ %{}) do
    owning_procedure = overrides[:procedure] || make_old_procedure()
    defaults = %{id: next_id,
                 animal_kind: "bovine",
                 description: "<p>Some html</p>",
                 procedure: owning_procedure,
                 procedure_id: owning_procedure.id}
    struct(OldProcedureDescription, Dict.merge(defaults, overrides))
  end

  def insert_old_procedure_description(overrides \\ %{}) do
    make_old_procedure_description(overrides)
    |> OldProcedureDescription.edit_action_changeset()
    |> OldRepo.insert!()
  end

  
  ## Old Reservations: This is just the fields at the top level, not
  ## nested data
  def make_old_reservation_fields(overrides \\ []) do
    overrides = 
      overrides
      |> Keyword.update(:first_date, Ecto.Date.cast!("2001-02-02"), &Ecto.Date.cast!/1)
      |> Keyword.update(:last_date, Ecto.Date.cast!("2021-12-12"), &Ecto.Date.cast!/1)
    
    other_defaults = %{id: next_id,
                 course: "VCM333",
                 time_bits: "011"}
    
    struct(OldReservation, Dict.merge(other_defaults, overrides))
  end

  ## Organizations
  def make_organization(overrides \\ %{}) do
    defaults = %{id: next_id,
                 short_name: "to",
                 full_name: "Test Organization"}
    struct(Organization, Dict.merge(defaults, overrides))
  end

  def insert_organization(overrides \\ %{}) do
    make_organization(overrides)
    |> Organization.edit_action_changeset()
    |> Repo.insert!()
  end

  ## Users

  # TODO: TEMP: put back null user object
  def make_user_kind("anonymous"), do: nil
  def make_user_kind(kind) when is_binary(kind),
    do: make_user(ability_group: make_ability_group(kind))

  def make_user(overrides \\ %{}) do
    defaults = %{id: next_id,
                 display_name: "Test User",
                 login_name: "user@example.com",
                 password: "password",
                 current_organization: make_organization()}
    struct(User, Dict.merge(defaults, overrides))
  end

  def insert_user(overrides \\ %{}) do
    make_user(overrides)
    |> User.update_action_changeset(%{})
    |> Repo.insert!()
  end

  def obey_tags(conn, tags) do
    if Map.has_key?(tags, :accessed_by) do
      Plug.Conn.assign(conn, :current_user, make_user_kind(tags.accessed_by))
    else
      conn
    end
  end
end
