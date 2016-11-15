defmodule Eecrit.Helpers.Bulma.Macros do
  defmacro augment_if(test, so_far, do: body) do
    quote bind_quoted: [test: test, so_far: so_far, body: body] do
      if test do
        [ body | so_far ]
      else
        so_far
      end
    end
  end
end

defmodule Eecrit.Helpers.Bulma do
  import Eecrit.Helpers.Bulma.Macros
  use Phoenix.HTML
  import Eecrit.Router.Helpers
  alias Phoenix.Controller
  alias Plug.Conn

  defp handler_to_tab_name(conn) do
    case {Controller.controller_module(conn), Controller.action_name(conn)} do
      {Eecrit.V2PageController, :index} -> "Home"
      {Eecrit.V2PageController, :about} -> "About"
      _ -> :not_relevant_to_navigation_bar
    end
  end

  defp tab_item(conn, name, path) do
    tab_item_class = if handler_to_tab_name(conn) == name do
      "nav-item is-tab is-active"
    else
      "nav-item is-tab"
    end

    link(name, to: path, class: tab_item_class)
  end

  defp maybe_home(so_far, conn) do
    augment_if conn.assigns.v2_current_user, so_far do 
      tab_item(conn, "Home", v2_page_path(conn, :index))
    end
  end

  defp maybe_about(so_far, conn) do
    [tab_item(conn, "About", v2_page_path(conn, :about)) | so_far]
  end

  defp maybe_logout(so_far, conn) do
    augment_if conn.assigns.v2_current_user, so_far do 
      tab_item(conn, "Logout", v2_session_path(conn, :logout))
    end
  end

  defp navbar_items(conn) do
    []
    |> maybe_home(conn)
    |> maybe_about(conn)
    |> maybe_logout(conn)
    |> Enum.reverse
  end


  defp user_description(conn) do
    if conn.assigns.v2_current_user do
      "Trial User at Demo U"
    else
      ""
    end
  end

  
  def v2_default_layout(conn, _opts) do
    layout_data = 
      %{left_picture_path: v2_page_path(conn, :index),
        user: user_description(conn),
        links: navbar_items(conn)
       }

    conn
    |> Controller.put_layout("v2_layout_default.html")
    |> Conn.assign(:layout_data, layout_data)
  end

end
