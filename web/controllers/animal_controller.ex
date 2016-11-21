defmodule Eecrit.AnimalController do
  use Eecrit.Web, :controller
  import Eecrit.LayoutView, only: [v2_default_layout: 2]
  plug :v2_default_layout
  plug :elm_single_page_app, "Animals"


  def elm_single_page_app(conn, app),
    do: assign(conn, :elm_single_page_app, app)

  def elm_launcher(conn, flags \\ []) do
    app = conn.assigns.elm_single_page_app

    # Note that all flags must be string-valued. This makes sure.
    js_flags =
      Enum.reduce(flags, [], fn({key, value}, acc) ->
        [~s{ #{key}: "#{value}", }  | acc ]
      end)
    text = 
      Phoenix.HTML.raw """
      <script type="text/javascript">
        const elmDiv = document.querySelector('#embed-elm-here');
        require("web/static/js/critter4us.js").#{app}.embed(elmDiv, {
          #{js_flags}
        })
      </script>
      """
    IO.puts (inspect text)
    assign(conn, :elm_launcher, text)
  end

  
  # alias Eecrit.ElmView

  def index(conn, _params) do
    conn
    |> elm_launcher(aStringFlag: "string", aNumberFlag: 333)
    |> render(Eecrit.ElmView, "elm_hook.html")
  end

  def new(conn, _params) do
    # ElmView.start(conn, "animals-new")
  end

end
