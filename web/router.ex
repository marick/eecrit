defmodule Eecrit.Router do
  use Eecrit.Web, :router
  import Eecrit.SessionPlugs, only: [add_current_user: 2,
                                     v2_add_current_user: 2,
                                     require_login: 2,
                                     require_admin: 2,
                                     require_superuser: 2]
  import Eecrit.SinglePageAppPlugs, only: [default_to_no_single_page_app: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :add_current_user
    plug :v2_add_current_user
    plug :default_to_no_single_page_app
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v2", Eecrit do 
    pipe_through [:browser]

    get "/", V2PageController, :index
    get "/about", V2PageController, :about
    get "/experiment", V2PageController, :experiment
    resources "/sessions", V2SessionController, only: [:delete]
    get "/animals/*rest", AnimalController, :all
    post "/log_in_demo_user", V2SessionController, :log_in_demo_user
    get "/unfinished", UnfinishedController, :index

    get "/*path", ElmController, :choose_page
  end  

  # TODO: I'm not sure where to store the fact that a user must have
  # ability X to access resource Y. Should it be here, to give a broad
  # overview? Or should it be attached to the resource (which would make
  # sense for finer-granularity permissions)?
  #
  # A related issue: we need not only to prevent a pipeline from delivering
  # the user to a page, we also need views to not display links to that page.
  # So it's more than just about controllers.
  

  # Not-logged-in users
  scope "/", Eecrit do
    pipe_through :browser

    get "/", PageController, :index
    get "/help", HelpController, :index
    # TODO: Remove this when more comfortable with embedding Elm
    get "/elm", ElmController, :index
    get "/iv/*path", IVController, :index
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

    scope "/reports" do
      get "/animal-use", ReportController, :animal_use
      post "/animal-use", ReportController, :animal_use
      get "/animal-reservations", ReportController, :animal_reservations
    end
  end

  # Controllers that require superuser permissions.
  scope "/", Eecrit do
    pipe_through [:browser, :require_login, :require_superuser]

    resources "/users", UserController
    resources "/ability_groups", AbilityGroupController
    resources "/organizations", OrganizationController
  end

  scope "/api", Eecrit do
    pipe_through :api
    
    resources "/animals", OldAnimalApiController, only: [:index]

    # Todo: how to do all the rest fakery from elm - if it's worth it
    post "/v2animals/create/:original_id", AnimalApiController, :create
    get "/v2animals", AnimalApiController, :index
    post "/v2animals", AnimalApiController, :update
    get "/v2animals/:id/history", AnimalApiController, :history
  end
end
