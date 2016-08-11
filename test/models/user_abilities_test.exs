defmodule Eecrit.UserAbilitiesTest do
  use Eecrit.ModelCase
  alias Eecrit.OldProcedure
  alias Eecrit.OldProcedureDescription
  alias Eecrit.OldAnimal

  import Canada, only: [can?: 2]
  @no_user nil
  @plain_user make_user(ability_group: make_ability_group("user"))
  @admin make_user(ability_group: make_ability_group("admin"))
  @superuser make_user(ability_group: make_ability_group("superuser"))

  test "procedures require admin abilities" do
    refute can?(@no_user, work_with(OldProcedure))
    refute can?(@plain_user, work_with(OldProcedure))
    assert can?(@admin, work_with(OldProcedure))
    assert can?(@superuser, work_with(OldProcedure))
  end

  test "procedure descriptions require admin abilities" do
    refute can?(@no_user, work_with(OldProcedureDescription))
    refute can?(@plain_user, work_with(OldProcedureDescription))
    assert can?(@admin, work_with(OldProcedureDescription))
    assert can?(@superuser, work_with(OldProcedureDescription))
  end

  test "animals require admin abilities" do
    refute can?(@no_user, work_with(OldAnimal))
    refute can?(@plain_user, work_with(OldAnimal))
    assert can?(@admin, work_with(OldAnimal))
    assert can?(@superuser, work_with(OldAnimal))
  end


end
