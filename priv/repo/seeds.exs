# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Eecrit.Repo.insert!(%Eecrit.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Eecrit.Organization
alias Eecrit.User
alias Ecto.Changeset
alias Eecrit.Repo

defmodule U do
  def fresh_start!() do
  end

  def add_user!(kwlist) do
    %User{}
    |> User.password_setting_changeset(as_map(kwlist))
    |> Repo.insert!
  end

  def add_org!(kwlist) do
    struct(Organization, as_map(kwlist))
    |> Repo.insert!
  end

  defp as_map(kwlist), do: Enum.into(kwlist, %{})
end


# Organizations
Repo.delete_all(Organization)
U.add_org! short_name: "uiuc_aacup",
           full_name: "University of Illinois Agricultural Animal Care and Use"

# Users
Repo.delete_all(User)
U.add_user! display_name: "User 1", login_name: "1@y.com", password: "password"
U.add_user! display_name: "User 2", login_name: "2@y.com", password: "password"


# Relationships
org = Repo.get_by(Organization, short_name: "uiuc_aacup") |> Repo.preload(:users)

for u <- Repo.all(User) do
  u
  |> Repo.preload([:organizations, :current_organization])
  |> Changeset.change
  |> Changeset.put_assoc(:current_organization, org)
  |> Changeset.put_assoc(:organizations, [org])
  |> Repo.update!
end    
