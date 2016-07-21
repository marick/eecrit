defmodule Eecrit.SessionPlugs do
  import Plug.Conn
  import Phoenix.Controller
  alias Eecrit.User
#  alias Eecrit.UserPermissions
  alias Eecrit.Router.Helpers

  def add_current_user(conn, repo) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        conn # Allows tests to bypass authentication

      user = user_id && repo.get(User, user_id) ->
        conn
        |> assign(:current_user, user)
        # |> assign(:permissions, repo.get_by(UserPermissions, user_id: user.id,
        #                                     organization_id: user.current_organization_id))
      true ->
        assign(conn, :current_user, nil)
    end
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

  # def authenticate_permission(conn = %{:assigns => %{:permissions => permissions}}, key) do
  #   if Map.get(permissions, key) do 
  #     conn
  #   else
  #     conn
  #     |> put_flash(:error, "You do not have permission to visit that page.")
  #     |> redirect(to: Helpers.page_path(conn, :index))
  #     |> halt()
  #   end
  # end

  # def authenticate_permission(conn, _key) do
  #   IO.puts("FAIL")
  #   conn
  #   |> put_flash(:error, "You do not have permission to visit that page.")
  #   |> redirect(to: Helpers.page_path(conn, :index))
  #   |> halt()
  # end
end
