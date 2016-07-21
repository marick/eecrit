defmodule Eecrit.Router do
  use Eecrit.Web, :router
  import Eecrit.SessionPlugs, only: [add_current_user: 2,
                                     require_login: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :add_current_user, Eecrit.Repo
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

  scope "/admin", Eecrit do
    pipe_through [:browser, :require_login]

    resources "/ability_groups", AbilityGroupController
    resources "/organizations", OrganizationController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Eecrit do
  #   pipe_through :api
  # end
end
