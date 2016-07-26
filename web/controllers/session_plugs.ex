defmodule Eecrit.SessionPlugs do
  import Plug.Conn
  import Phoenix.Controller
  import Ecto.Query
  alias Eecrit.User
  alias Eecrit.Repo
  alias Eecrit.AbilityGroupChooser
  alias Eecrit.AbilityGroup
  alias Eecrit.Router.Helpers

  def add_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    IO.puts "SESSION"
    Apex.ap conn.private[:plug_session]

    cond do
      user = conn.assigns[:current_user] ->
        conn # Allows tests to fake a logged-in user

      user = user_id && fetch_user(user_id) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  @precompiled_part_of_query from u in User,
    preload: [:current_organization],

    # Find id of ability group for user X organization
    join: c in AbilityGroupChooser,
    where: u.id == c.user_id and u.current_organization_id == c.organization_id,
    
    # Don't think there's a way to preload multi-key join table
    join: a in AbilityGroup,
    where: c.ability_group_id == a.id,
    
    select: {u, a}, limit: 1


  def fetch_user(user_id) do
    query = @precompiled_part_of_query |> where([u], u.id == ^user_id)

    case Repo.one(query) do 
      {user, abilities} ->
        Map.put(user, :ability_group, abilities)
      _ ->
        nil
    end
  end

  def require_login(conn, _opts \\ %{}) do
    require_X(conn, conn.assigns.current_user, "Please log in.")
  end

  def require_admin(conn, _opts) do
    require_X(conn, conn.assigns.current_user.ability_group.is_admin,
                    "You aren't permitted to see that page.")
  end

  def require_superuser(conn, _opts) do
    require_X(conn, conn.assigns.current_user.ability_group.is_superuser,
                    "You aren't permitted to see that page.")
  end

  defp require_X(conn, permitted?, flash) do
    if permitted? do
      conn
    else
      conn
      |> put_flash(:error, flash)
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
