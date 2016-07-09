defmodule Eecrit.Router do
  use Eecrit.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Eecrit.Auth, repo: Eecrit.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Eecrit do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/critter4us", Eecrit do
    pipe_through [:browser, :authenticate_user]

    resources "/organizations", OrganizationController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Eecrit do
  #   pipe_through :api
  # end
end
