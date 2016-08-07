defmodule Eecrit.Test.Makers do
  alias Eecrit.Repo
  alias Eecrit.OldRepo
  alias Eecrit.User
  alias Eecrit.Organization
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

  def insert_old_procedure(overrides \\ %{})
  def insert_old_procedure(struct = %OldProcedure{}) do
    struct
    |> OldProcedure.edit_action_changeset()
    |> OldRepo.insert!()
  end

  def insert_old_procedure(overrides) do
    make_old_procedure(overrides)
    |> insert_old_procedure()
  end

  ## Old Procedure Descriptions
  def make_old_procedure_description(overrides \\ %{}) do
    owning_procedure = make_old_procedure()
    defaults = %{id: next_id,
                 animal_kind: "bovine",
                 description: "<p>Some html</p>",
                 procedure: owning_procedure}
    struct(OldProcedureDescription, Dict.merge(defaults, overrides))
  end

  def insert_old_procedure_description(overrides \\ %{}) do
    description = make_old_procedure_description(overrides)

    description
    |> OldProcedureDescription.edit_action_changeset()
    |> OldRepo.insert!()
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
      user = make_user(ability_group: make_ability_group(tags.accessed_by))
      Plug.Conn.assign(conn, :current_user, user)
    else
      conn
    end
  end
end
