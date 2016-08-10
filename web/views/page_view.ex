defmodule Eecrit.PageView do
  use Eecrit.Web, :view
  use Eecrit.WebAssembly

  def commands(conn, current_user) do
    raw_builder do
      unless current_user do
        build_commands([{"Please log in", session_path(conn, :new)}])
      end
      
      if empowered?(current_user, :is_admin) do
        build_commands([{"Work With Animals", old_animal_path(conn, :index)},
                        {"Work With Procedures", old_procedure_path(conn, :index)}])
      end

      if empowered?(current_user, :is_superuser) do 
        build_commands([{"Users", user_path(conn, :index)},
                        {"Organizations", organization_path(conn, :index)},
                        {"Ability Groups", ability_group_path(conn, :index)}])
      end 
    end
  end

  defp empowered?(current_user, ability) do
    current_user && Map.get(current_user.ability_group, ability)
  end

  defp build_commands(tuples) do
    hr
    p [class: "lead"] do
      for {text, path} <- tuples do
        text button_link(text, path)
        text " "
      end
    end
  end

  defp button_link(text, path) do
    text
    |> link(to: path, class: "btn btn-primary btn-lg")
    |> safe_to_string
  end
end
