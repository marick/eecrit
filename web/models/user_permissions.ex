defmodule Eecrit.UserPermissions do
  use Eecrit.Web, :model

  schema "user_permissions" do
    belongs_to :user, Eecrit.User
    belongs_to :organization, Eecrit.Organization
    belongs_to :permissions, Eecrit.Permissions
  end
end
