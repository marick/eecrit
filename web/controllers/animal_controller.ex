defmodule Eecrit.AnimalController do
  use Eecrit.Web, :controller
  import Eecrit.LayoutView, only: [v2_default_layout: 2]
  import Eecrit.SinglePageAppPlugs, only: [set_single_page_app_name: 2,
                                           render_single_page_app: 2]

  plug :v2_default_layout
  plug :set_single_page_app_name, "Animals"
  
  def index(conn, _params) do
    render_single_page_app(conn, desire: "ViewAllInUseAnimals")
  end

  def new(_conn, _params) do
    # launch with different flags
  end

end
