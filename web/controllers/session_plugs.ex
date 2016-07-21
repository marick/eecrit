defmodule Eecrit.SessionPlugs do
  import Plug.Conn
  import Phoenix.Controller
  alias Eecrit.User
  alias Eecrit.Repo
  alias Eecrit.AbilityGroupChooser
  alias Eecrit.Router.Helpers

  def add_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        conn # Allows tests to bypass authentication

      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :current_user, add_abilities(user))
      true ->
        assign(conn, :current_user, nil)
    end
  end

  defp add_abilities(user) do
    choice =
      AbilityGroupChooser
      |> Repo.get_by(user_id: user.id, organization_id: user.current_organization_id)
      |> Repo.preload(:ability_group)
    IO.puts("Fetched abilities: #{inspect choice.ability_group}")
    Map.put(user, :abilities, choice.ability_group)
  end

  def require_login(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to see that page.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
