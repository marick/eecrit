alias Eecrit.Organization
alias Eecrit.AbilityGroup
alias Eecrit.AbilityGroupChooser
alias Eecrit.User
alias Ecto.Changeset
alias Eecrit.Repo

defmodule Eecrit.U do
  def fresh_start!() do
    Repo.delete_all(AbilityGroup)
    Repo.delete_all(Organization)
    Repo.delete_all(User)
  end

  def add_user!(kwlist) do
    existing = existing_user(kwlist[:login_name])
    if existing, do: Repo.delete(existing)
      
    %User{}
    |> User.password_setting_changeset(as_map(kwlist))
    |> Repo.insert!
  end

  def add_org!(kwlist), do: add_x!(Organization, kwlist)
  def add_ability_group!(kwlist), do: add_x!(AbilityGroup, kwlist)

  def put_user_in_org!(login_name, org_short_name, ability_group_name) do
    user =
      existing_user(login_name)
      |> Repo.preload([:organizations, :current_organization])

    org = Repo.get_by(Organization, short_name: org_short_name)

    Changeset.change(user)
    |> Changeset.put_change(:current_organization_id,
                            (user.current_organization || org).id)
    |> Repo.update!

    Changeset.change(user)
    |> Changeset.put_assoc(:organizations,
                           Enum.map([org | user.organizations], &Changeset.change/1))
    |> Repo.update

    group = Repo.get_by(AbilityGroup, name: ability_group_name)
    Repo.insert!(%AbilityGroupChooser{user_id: user.id,
                                      organization_id: org.id,
                                      ability_group_id: group.id})
  end

  defp existing_user(login_name), do: Repo.get_by(User, login_name: login_name)

  defp add_x!(module, kwlist), do: struct(module, as_map(kwlist)) |> Repo.insert!

  defp as_map(kwlist), do: Enum.into(kwlist, %{})
end
