defmodule Eecrit.Test.Makers do
  alias Eecrit.Repo
  alias Eecrit.User
  alias Eecrit.Organization

  # TODO: simplify this with macros or higher-level functions

  ## Ability Groups
  def make_ability_group(overrides \\ %{}) do
  end

  def insert_ability_group(overrides \\ %{}) do
  end

  ## Organizations
  def make_organization(overrides \\ %{}) do
    defaults = %{short_name: "to",
                 full_name: "Test Organization"}
    struct(Organization, Dict.merge(defaults, overrides))
  end

  def insert_organization(overrides \\ %{}) do
    make_organization(overrides)
    |> Organization.changeset()
    |> Repo.insert!()
  end

  ## Users
  def make_user(overrides \\ %{}) do
    defaults = %{display_name: "Test User",
                 login_name: "user@example.com",
                 password: "password",
                 organization: make_organization
    struct(User, Dict.merge(defaults, overrides))
  end

  def insert_user(overrides \\ %{}) do
    make_user(overrides)
    |> User.checking_creation_changeset(%{})
    |> Repo.insert!()
  end
end
