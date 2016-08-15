defmodule Eecrit.UserAbilitiesTest do
  alias Eecrit.UserAbilities
  use Eecrit.ModelCase
  alias Eecrit.OldProcedure
  alias Eecrit.OldProcedureDescription
  alias Eecrit.OldAnimal
  alias Eecrit.Organization

  import Canada.Can, only: [can?: 3]
  @no_user nil
  @plain_user make_user(ability_group: make_ability_group("user"))
  @admin make_user(ability_group: make_ability_group("admin"))
  @superuser make_user(ability_group: make_ability_group("superuser"))

  # NOTE: For newer models, don't bother writing tests here. There are
  # controller tests that imply what these directly test. The same would
  # be true in the other direction, but the integration test is more important. 

  test "procedures require admin abilities" do
    refute can?(@no_user, :work_with, OldProcedure)
    refute can?(@plain_user, :work_with, OldProcedure)
    assert can?(@admin, :work_with, OldProcedure)
    assert can?(@superuser, :work_with, OldProcedure)
  end

  test "procedure descriptions require admin abilities" do
    refute can?(@no_user, :work_with, OldProcedureDescription)
    refute can?(@plain_user, :work_with, OldProcedureDescription)
    assert can?(@admin, :work_with, OldProcedureDescription)
    assert can?(@superuser, :work_with, OldProcedureDescription)
  end

  test "animals require admin abilities" do
    refute can?(@no_user, :work_with, OldAnimal)
    refute can?(@plain_user, :work_with, OldAnimal)
    assert can?(@admin, :work_with, OldAnimal)
    assert can?(@superuser, :work_with, OldAnimal)
  end

  test "organizations require admin abilities" do
    refute can?(@no_user, :work_with, Organization)
    refute can?(@plain_user, :work_with, Organization)
    refute can?(@admin, :work_with, Organization)
    assert can?(@superuser, :work_with, Organization)
  end
end
