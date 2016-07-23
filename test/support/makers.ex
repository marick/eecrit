defmodule Eecrit.Test.Makers do
  alias Eecrit.Repo
  alias Eecrit.User
  alias Eecrit.Organization
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

  ## Organizations
  def make_organization(overrides \\ %{}) do
    defaults = %{id: next_id,
                 short_name: "to",
                 full_name: "Test Organization"}
    struct(Organization, Dict.merge(defaults, overrides))
  end

  ## Users
  def make_user(overrides \\ %{}) do
    defaults = %{id: next_id,
                 display_name: "Test User",
                 login_name: "user@example.com",
                 password: "password"}
    struct(User, Dict.merge(defaults, overrides))
  end

  def insert_user(overrides \\ %{}) do
    make_user(overrides)
    |> User.checking_creation_changeset(%{})
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
