defmodule Eecrit.Router do
  use Eecrit.Web, :router
  import Eecrit.SessionPlugs, only: [add_current_user: 2,
                                     require_login: 2,
                                     require_admin: 2,
                                     require_superuser: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :add_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Not-logged-in users
  scope "/", Eecrit do
    pipe_through :browser

    get "/", PageController, :index
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  # Only for logged-in users
  scope "/", Eecrit do
    pipe_through [:browser, :require_login]
  end

  # Controllers that require Admin permissions.
  scope "/", Eecrit do
    pipe_through [:browser, :require_login, :require_admin]

    resources "/animals", OldAnimalController
    resources "/procedures", OldProcedureController
    resources "/procedure_descriptions", OldProcedureDescriptionController
  end

  # Controllers that require superuser permissions.
  scope "/", Eecrit do
    pipe_through [:browser, :require_login, :require_superuser]

    resources "/users", UserController
    resources "/ability_groups", AbilityGroupController
    resources "/organizations", OrganizationController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Eecrit do
  #   pipe_through :api
  # end
end
