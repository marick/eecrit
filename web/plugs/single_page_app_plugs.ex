defmodule Eecrit.SinglePageAppPlugs do
  import Plug.Conn
  alias Phoenix.Controller
  alias Eecrit.ElmView
  alias Plug.CSRFProtection

  @launcher :eecrit_spa_launcher
  @app_name_field :eecrit_spa_name

  def default_to_no_single_page_app(conn, _opts),
    do: assign(conn, @launcher, "")

  def set_single_page_app_name(conn, name),
    do: assign(conn, @app_name_field, name)

  # Following are not actually plugs, but it seems best to keep all
  # the code together.

  defp get_single_page_app_name(conn),
    do: get_in(conn.assigns, [@app_name_field])
  
  # Each action will start the app in a different way. For example,
  # the `index` action will show a bunch of animals (and the user may
  # then choose to create a new animal). But the `new` action will
  # start the user creating a new animal (and the user may then choose
  # to see all the animals).
  #
  # Which "part" of the app shows first is controlled by flags.
  defp enable_single_page_app(conn, flags) do
    # Note that all flags must be string-valued. The quoting makes sure.
    js_flags =
      Enum.reduce(flags, [], fn({key, value}, acc) ->
        [~s{ #{key}: "#{value}", }  | acc ]
      end)
    text = 
      Phoenix.HTML.raw """
      <script type="text/javascript">
        const elmDiv = document.querySelector('#embed-elm-here');
        require("web/static/js/critter4us.js").#{get_single_page_app_name(conn)}.embed(elmDiv, {
          #{js_flags}
        })
      </script>
      """
    assign(conn, @launcher, text)
  end
    
  def render_single_page_app(conn, flags \\ []) do
    better_flags = [{:authToken, Plug.CSRFProtection.get_csrf_token} | flags]
    conn
    |> enable_single_page_app(better_flags)
    |> Controller.render(ElmView, "elm_hook.html")
  end
end
