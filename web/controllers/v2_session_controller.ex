defmodule Eecrit.V2SessionController do
  use Eecrit.Web, :controller
  import Phoenix.Controller
  alias Plug.Conn

  def log_in_demo_user(conn, _params) do
    conn
    |> assign(:v2_current_user, true)
    |> put_session(:v2_logged_in, true)
    |> configure_session(renew: true)
    |> redirect(to: v2_page_path(conn, :index))
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: v2_page_path(conn, :index))
  end
end
