defmodule Eecrit.AnimalController do
  use Eecrit.Web, :controller

  # As far as I can tell, this can't be done inside a router.ex
  # pipeline because the layout template uses path functions that
  # are generated from router.ex. 
  import Eecrit.LayoutView, only: [v2_default_layout: 2]
  plug :v2_default_layout

  # The idea is that this controller provides different ways of starting
  # one app. This is that app.
  @single_page_app "Animals"

  # Each action will start the app in a different way. For example,
  # the `index` action will show a bunch of animals (and the user may
  # then choose to create a new animal). But the `new` action will
  # start the user creating a new animal (and the user may then choose
  # to see all the animals).
  #
  # Which "part" of the app shows first is controlled by flags.
  def launch_page_app_with_flags(conn, flags \\ []) do
    # Note that all flags must be string-valued. The quoting makes sure.
    js_flags =
      Enum.reduce(flags, [], fn({key, value}, acc) ->
        [~s{ #{key}: "#{value}", }  | acc ]
      end)
    text = 
      Phoenix.HTML.raw """
      <script type="text/javascript">
        const elmDiv = document.querySelector('#embed-elm-here');
        require("web/static/js/critter4us.js").#{@single_page_app}.embed(elmDiv, {
          #{js_flags}
        })
      </script>
      """
    assign(conn, :elm_launcher, text)
  end

  
  # alias Eecrit.ElmView

  def index(conn, _params) do
    conn
    |> launch_page_app_with_flags(aStringFlag: "string", aNumberFlag: 5845)
    |> render(Eecrit.ElmView, "elm_hook.html")
  end

  def new(conn, _params) do
    # launch with different flags
  end

end
