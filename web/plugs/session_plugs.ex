defmodule Eecrit.SessionPlugs do
  import Plug.Conn
  import Phoenix.Controller
  import Ecto.Query
  alias Eecrit.User
  alias Eecrit.Repo
  alias Eecrit.AbilityGroupChooser
  alias Eecrit.AbilityGroup
  alias Eecrit.Router.Helpers

  def v2_add_current_user(conn, _opts) do
    assign(conn, :v2_current_user, get_session(conn, :v2_logged_in))
  end




  
  @doc """
  Fetches a userid from the session. If found, looks up the user
  and assigns it to `conn.assigns.current_user`, which is otherwise
  assigned `nil`. 

  If the `conn` already has a current user, it is left alone. This
  allows tests to fake a logged-in user.
  """
  def add_current_user(conn, opts) do
    if conn.assigns[:current_user] do
      conn
    else
      add_current_user(conn, opts, get_session(conn, :user_id))
    end
  end

  @doc """
  See add_current_user/2. This takes a user_id for testing purposes.
  """

  def auth_token_name, do: "user socket auth token"
  
  def add_current_user(conn, _opts, user_id) do
    if user = user_id && fetch_user(user_id) do
      conn
      |> assign(:current_user, user)
      |> assign(:auth_token, Phoenix.Token.sign(conn, auth_token_name, user.id))
    else
      assign(conn, :current_user, nil)
    end
  end

  def require_login(conn, _opts) do
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

  # Private
  
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



  @precompiled_part_of_query from u in User,
    # Find id of ability group for user X organization
    join: c in AbilityGroupChooser,
    where: u.id == c.user_id and u.current_organization_id == c.organization_id,
    
    join: a in AbilityGroup,
    where: c.ability_group_id == a.id,

    preload: [:current_organization, ability_group: a]

  defp fetch_user(user_id) do
    @precompiled_part_of_query
    |> where([u], u.id == ^user_id)
    |> Repo.one
  end
end
