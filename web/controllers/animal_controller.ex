defmodule Eecrit.AnimalController do
  use Eecrit.Web, :controller
  import Eecrit.LayoutView, only: [v2_default_layout: 2]
  import Eecrit.SinglePageAppPlugs, only: [set_single_page_app_name: 2,
                                           render_single_page_app: 2]
  alias Plug.CSRFProtection

  plug :v2_default_layout
  plug :set_single_page_app_name, "Animals"
  
  def all(conn, _params) do
    render_single_page_app(conn, csrfToken: CSRFProtection.get_csrf_token)
  end
end
