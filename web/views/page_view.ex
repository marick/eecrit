defmodule Eecrit.PageView do
  use Eecrit.Web, :view


  def commands(conn, nil), do: wrapper([{"Please log in", session_path(conn, :new)}])

  
  def commands(conn, current_user) do
    admins = if empowered?(current_user, :is_admin) do
      wrapper([{"Work With Animals", old_animal_path(conn, :index)},
               {"Work With Procedures", old_procedure_path(conn, :index)}])
    end

    superusers = if empowered?(current_user, :is_superuser) do 
      wrapper([{"Users", user_path(conn, :index)},
               {"Organizations", organization_path(conn, :index)},
               {"Ability Groups", ability_group_path(conn, :index)}])
    end

    [admins, superusers]
    |> Enum.filter(&(&1))
    |> concat_safes
  end

  defp empowered?(current_user, ability) do
    current_user && Map.get(current_user.ability_group, ability)
  end

  defp wrapper(tuples) do
    embed =
      tuples
      |> Enum.map(fn({text, path}) -> button_link(text, path) end)
      |> concat_safes
    
    ~E"""
    <hr/>
    <p class="lead">
    <%= embed %>
    </p>
    """
  end

  defp concat_safes(safes) do
    safes
    |> Enum.reduce("", fn(safe, acc) -> "#{acc} #{safe_to_string(safe)}" end)
    |> raw
  end
    

  defp button_link(text, path) do 
    link(text, to: path, class: "btn btn-primary btn-lg")
  end
  
end
