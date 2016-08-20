ExUnit.start(exclude: [:skip])

Ecto.Adapters.SQL.Sandbox.mode(Eecrit.Repo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Eecrit.OldRepo, :manual)

path_fn_map = %{
  Eecrit.OldProcedure => :old_procedure_path,
  Eecrit.OldProcedureDescription => :old_procedure_description_path,
  Eecrit.OldAnimal => :old_animal_path,
  Eecrit.User => :user_path,
  Eecrit.Organization => :organization_path,
  Eecrit.AbilityGroup => :ability_group_path,
  Eecrit.Session => :session_path,
}

alias RoundingPegs.ExUnit.PhoenixState
%{endpoint: Eecrit.Endpoint,
  path_module: Eecrit.Router.Helpers,
  path_fns: path_fn_map}
|> PhoenixState.start
