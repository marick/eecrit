defmodule Eecrit.SessionController do
  use Eecrit.Web, :controller
  alias Eecrit.Repo
  alias Eecrit.Auth

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"login_name" => login_name,
                                    "password" => password}}) do 
    case Auth.login_by_credentials(conn, login_name, password, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Either your email address or password is wrong.")
        |> render("new.html")
    end
  end
end
