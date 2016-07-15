defmodule Eecrit.AbilityGroupChooser do
  use Eecrit.Web, :model

  schema "ability_group_chooser" do
    belongs_to :user, Eecrit.User
    belongs_to :organization, Eecrit.Organization
    belongs_to :ability_group, Eecrit.AbilityGroup
  end
end
