defmodule Eecrit.UsersOrganizations do
  use Eecrit.Web, :model

  @primary_key false

  schema "users_organizations" do
    belongs_to :user, Eecrit.User
    belongs_to :organization, Eecrit.Organization
  end
end

