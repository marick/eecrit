defmodule Eecrit.SessionController do
  use Eecrit.Web, :controller
  alias Eecrit.Repo
  alias Eecrit.SessionPlugs
  alias Eecrit.User
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller
  import Plug.Conn

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"login_name" => login_name,
                                    "password" => password}}) do 
    case authenticate(conn, login_name, password) do
      {:ok, conn} ->
        conn
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Either your email address or password is wrong.")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: page_path(conn, :index))
  end

  defp record_user_in_session(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  defp authenticate(conn, login_name, password) do
    user = Repo.get_by(User, login_name: login_name)

    cond do
      user && checkpw(password, user.password_hash) ->
        {:ok, record_user_in_session(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()  # avoid timing attacks.
        {:error, :not_found, conn}
    end
  end
end
