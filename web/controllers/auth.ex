defmodule Eecrit.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller
  alias Eecrit.User
  alias Eecrit.UserPermissions
  alias Eecrit.Router.Helpers

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        conn # Allows tests to bypass authentication

      user = user_id && repo.get(User, user_id) ->
        IO.puts("In Auth.call #{user_id}")
        conn
        |> assign(:current_user, user)
        |> assign(:permissions, repo.get_by(UserPermissions, user_id: user.id,
                                            organization_id: user.current_organization_id))
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to see that page.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  def authenticate_permission(conn = %{:assigns => %{:permissions => permissions}}, key) do
    if Map.get(permissions, key) do 
      conn
    else
      conn
      |> put_flash(:error, "You do not have permission to visit that page.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  def authenticate_permission(conn, _key) do
    IO.puts("FAIL")
    conn
    |> put_flash(:error, "You do not have permission to visit that page.")
    |> redirect(to: Helpers.page_path(conn, :index))
    |> halt()
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_credentials(conn, login_name, password, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(User, login_name: login_name)

    cond do
      user && checkpw(password, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()  # avoid timing attacks.
        {:error, :not_found, conn}
    end
  end

  def destroy_session(conn) do
    configure_session(conn, drop: true)
  end
end
